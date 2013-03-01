require 'cgi'

class SessionsController < ApplicationController
  skip_before_filter :verify_authenticity_token, :only => :create
  
  def new
  end

  def create
    if cookies.blank?
      flash[:notice] = "Your browser does not have cookies enabled. Please refer to your browser's documentation to enable cookies."
      render :action => :new
    else
      logout_keeping_session!
      password_authentication
    end
  end

  def destroy
    logout_killing_session!
    delete_cc_cookie
    delete_blog_cookie
    flash[:notice] = "You have been logged out."
    redirect_back_or_default(root_path)
  end

  # for cucumber testing only
  def backdoor
    logout_killing_session!
    self.current_visitor = User.find_by_login!(params[:username])
    head :ok
  end

  # verify a CC token
  def verify_cc_token
    begin
      token = cookies[CCCookieAuth.cookie_name]
      raise 'non-existent token' unless token
      valid = CCCookieAuth.verify_auth_token(token,request.remote_ip)
      raise 'invalid token' unless valid
      login = token.split(CCCookieAuth.token_separator).first
      raise 'token parse error' unless login
      user = User.find_by_login(login)
      raise 'bogus user' unless user
      values = {:login => login, :first => user.first_name, :last => user.last_name}
      student = user.portal_student
      teacher = user.portal_teacher
      values[:group] = user.group_account_class_id ? true : false
      if student
        values[:class_words] = student.clazzes.map{ |c| c.class_word }
        values[:teacher] = false
        values[:classes] = student.clazzes.map{|c|
          cohorts = c.teachers.map{|t| t.cohorts}.flatten.compact.uniq
          val = {:teacher => c.teacher.name, :word => c.class_word, :name => c.name, :cohorts => cohorts}
          offerings = c.offerings
          offerings = offerings.select{|o| o.active && o.runnable.is_a?(ExternalActivity)}
          offerings = offerings.select{|o|
            runnable_url = o.runnable.url.gsub(/\/\s*$/,'')
            save_path = o.runnable.save_path.gsub(/\/\s*$/,'')
            referrer = request.referrer.gsub(/\/\s*$/,'')
            town_level_referrer = referrer.gsub(/(\?task=(?:baseline\/)?\d+)\/\d+$/) {|m| $1 }
            runnable_url == referrer || save_path == referrer || save_path == town_level_referrer
          }
          offering = offerings.first
          if offering # what do we do if somehow multiple external activities with the same url are assigned to the same class??
            learner = offering.find_or_create_learner(student)
            val[:learner] = learner.id if learner
          end
          val
        }
        values[:cohorts] = values[:classes].map{|vc| vc[:cohorts]}.flatten.compact.uniq.map{|c| c.name}
      end
      if teacher
        values[:class_words] = teacher.clazzes.map{ |c| c.class_word }
        valuse[:cohorts] = teacher.cohorts.map{|c| c.name }
        values[:teacher] = true
      end
      render :json => values
    rescue Exception => e
      render :text => "authentication failure: #{e.message}", :status => 403
    end
  end
  
  # verify a remote login attempt
  def remote_login
    delete_blog_cookie   # first delete any remaining blog cookies
    user = User.authenticate(params[:login], params[:password])
    if user
      self.current_visitor = user
      save_cc_cookie
      save_blog_cookie
      values = {:login => user.login, :first => user.first_name, :last => user.last_name}
      render :json => values
    else
      error = "authentication failure: invalid user or password"
      values = {:error => error}
      #render :text => error, :status => 403
      render :json => values, :status => 403
    end
  end

  # silently logout using a post request
  def remote_logout
    logout_killing_session!
    delete_cc_cookie
    delete_blog_cookie
    message = "logged out."
    values = {:message => message}
    render :json => values
  end

  protected
  
  def password_authentication
    user = User.authenticate(params[:login], params[:password])
    if user
      if user.group_account_class_id
        # if it's outside of school hours, fail the login
        # TODO Can we adjust school hours based on the user's school's time zone?
        t = TZ[:eastern].utc_to_local(Time.now.utc)
        hour = t.hour
        if hour < current_project.school_start_hour || hour >= current_project.school_end_hour || t.saturday? || t.sunday?
          note_failed_signin_time_restriction
          @login = params[:login]
          @remember_me = params[:remember_me]
          self.current_visitor = User.anonymous
          redirect_to :home
          return
        end
      end
      self.current_visitor = user
      session[:original_user_id] = current_visitor.id
      successful_login
    else
      note_failed_signin
      @login = params[:login]
      @remember_me = params[:remember_me]
      self.current_visitor = User.anonymous
      redirect_to :home
    end
  end
  
  def successful_login
    delete_blog_cookie   # first delete any remaining blog cookies
    new_cookie_flag = (params[:remember_me] == "1")
    handle_remember_cookie! new_cookie_flag
    save_cc_cookie
    save_blog_cookie
    flash[:notice] = "Logged in successfully"
    
    redirect_path = root_path
    
    if APP_CONFIG[:recent_activity_on_login] && current_visitor.portal_teacher
      portal_teacher = current_visitor.portal_teacher
      if (portal_teacher.teacher_clazzes.select{|tc| tc.active }).count > 0
        # Teachers with active classes are redirected to the "Recent Activity" page
        redirect_path = recent_activity_path
      end
    end
    
    redirect_to(redirect_path) # unless !check_student_security_questions_ok
  end

  def note_failed_signin
    flash[:error] = "Couldn't log you in as '#{params[:login]}'"
    logger.warn "Failed login for '#{params[:login]}' from #{request.remote_ip} at #{Time.now.utc}"
  end

  def note_failed_signin_time_restriction
    flash[:error] = "The account '#{params[:login]}' is only allowed to log in during school hours (#{current_project.school_hours})"
  end
  # 2011-11-07 NP: moved to ApplicationController 
  # def check_student_security_questions_ok
  #   if current_project && current_project.use_student_security_questions && !current_visitor.portal_student.nil? && current_visitor.security_questions.size < 3
  #     redirect_to(edit_user_security_questions_path(current_visitor))
  #     return false
  #   end
  #   return true
  # end

  # authenticated system does this by default: 
  #def logged_in?
  #  !!current_visitor
  #end
  #
  # but out current_visitor will be 'anonymous'
  # because we always have a current_visitor
  def logged_in?
    return (!(current_visitor.nil? || current_visitor == User.anonymous))
  end

  def cookie_domain
    if defined? @cookie_domain
      return @cookie_domain
    end

    # use wildcard domain (last two parts ".concord.org") for this cookie
    @cookie_domain = request.host
    @cookie_domain = '.concord.org' if @cookie_domain =~ /\.concord\.org$/

    return @cookie_domain
  end

  def delete_cc_cookie
    #cookies.delete CCCookieAuth.cookie_name.to_sym
    if cookies.kind_of? ActionDispatch::Cookies::CookieJar
      cookies.delete(CCCookieAuth.cookie_name.to_sym, {:domain => cookie_domain})
    else
      cookies.delete CCCookieAuth.cookie_name.to_sym
    end
  end

  def delete_blog_cookie
    #cookies.delete CCCookieAuth.cookie_name.to_sym
    # cookies match: wordpress_* and wordpress_logged_in_*
    cookies.each do |key, val|
      if key.to_s =~ /^wordpress_/
        if cookies.kind_of? ActionDispatch::Cookies::CookieJar
          cookies.delete(key, {:domain => cookie_domain})
        else
          cookies.delete key
        end
      end
    end
  end

  def save_cc_cookie
    token = CCCookieAuth.make_auth_token(current_visitor.login, request.remote_ip)
    #cookies[CCCookieAuth.cookie_name.to_sym] = token
    cookies[CCCookieAuth.cookie_name.to_sym] = {:value => token, :domain => cookie_domain }
  end

  def save_blog_cookie
    begin
      # log in to the blog
      resp = Wordpress.new.log_in_user(current_visitor.login, params[:password])

      # capture the cookies set by the blog
      # and set those cookies in our current domain
      #   cookies match: wordpress_* and wordpress_logged_in_*
      resp['Set-Cookie'].split(/[,\;] |\n/).each do |token|
        k,v = token.split("=")
        if k.to_s =~ /^wordpress_/
          cookies[k.to_sym] = {:value => CGI::unescape(v), :domain => cookie_domain }
        end
      end
    rescue
      # FIXME How do we handle a login failure?
    end
  end
end
