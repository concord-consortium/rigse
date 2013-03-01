class UsersController < ApplicationController

  def index
    if params[:mine_only]
      @users = User.search(params[:search], params[:page], self.current_visitor)
    else
      @users = User.search(params[:search], params[:page], nil)
    end
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @users }
    end
  end
  
  # GET /users/1
  # GET /users/1.xml
  def show
    @user = User.find(params[:id])
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @user }
    end
  end
  
  # GET /users/1/edit
  def preferences
    @user = User.find(params[:id])
    @roles = Role.all
    unless @user.changeable?(current_user)
      flash[:warning]  = "You need to be logged in first."
      redirect_to login_url
    end
  end
  
   # /users/1/switch
  def switch
    # @original_user is setup in app/controllers/application_controller.rb
    unless @original_user.has_role?('admin', 'manager')
      redirect_to home_path
    else
      if request.get?
        @user = User.find(params[:id])
        all_users = User.active.all
        all_users.delete(current_visitor)
        all_users.delete(User.anonymous)
        all_users.delete_if { |user| user.has_role?('admin') } unless @original_user.has_role?('admin')

        recent_users = []
        (session[:recently_switched_from_users]  || []).each do |user_id|
          recent_user = all_users.find { |u| u.id == user_id }
          recent_users << all_users.delete(recent_user) if recent_user
        end

        users = all_users.group_by do |u|
          case
          when u.default_user   then :default_users
          when u.portal_student then :student
          when u.portal_teacher then :teacher
          else :regular
          end
        end

        # to avoid nil values, initialize everything to an empty array if it's non-existent
        # users[:student] ||= []
        # users[:regular] ||= []
        # users[:default_users] ||= []
        # users[:student].sort! { |a, b| a.first_name.downcase <=> b.first_name.downcase }
        # users[:regular].sort! { |a, b| a.first_name.downcase <=> b.first_name.downcase }
        [:student, :regular, :default_users, :student, :teacher].each do |ar|
          users[ar] ||= []
          users[ar].sort! { |a, b| a.last_name.downcase <=> b.last_name.downcase }
        end
        @user_list = [ 
          { :name => 'recent' ,   :users => recent_users     } ,
          { :name => 'guest',     :users => [User.anonymous] } ,
          { :name => 'regular',   :users => users[:regular]  } ,
          { :name => 'students',  :users => users[:student]  } ,
          { :name => 'teachers',  :users => users[:teacher]  } 
        ]
        if users[:default_users] && users[:default_users].size > 0
          @user_list.insert(2, { :name => 'default', :users => users[:default_users] })
        end
      elsif request.put?
        if params[:commit] == "Switch"
          if switch_to_user = User.find(params[:user][:id])
            unless session[:original_user_id]  # session[:original_user_auth_token]
              session[:original_user_id] = current_visitor.id
            end
            sign_out self.current_visitor
            sign_in switch_to_user
            recently_switched_from_users = (session[:recently_switched_from_users] || []).clone
            recently_switched_from_users.insert(0, current_visitor.id)
            self.current_visitor=(switch_to_user)
            session[:recently_switched_from_users] = recently_switched_from_users.uniq
            
          end
        elsif params[:commit] =~ /#{@original_user.name}/
          self.current_visitor=(@original_user)
        end
        redirect_to home_path
      end
    end
  end
  
  
  def reset_password
    p = Password.new(:user_id => @user.id)
    p.save(:validate => false) # we don't need the user to have a valid email address...
    session[:return_to] = request.referer
    redirect_to change_password_path(:reset_code => p.reset_code)
  end

end