class HomeController < ApplicationController
  caches_page   :project_css
  
  def index
    all_notices_ids = Array.new
    all_roles_of_user = Array.new
    all_role = Role.all
    all_role.each do |role|
      if(current_user.has_role?(role.title))
        all_roles_of_user << role.id     
      end      
    end
    
    last_collapsed_at_time_obj = Admin::NoticeUserDisplayStatus.find_by_user_id(current_user.id)
    
    if(!last_collapsed_at_time_obj.nil? and last_collapsed_at_time_obj.collapsed_status == true)
      last_collapsed_at_time = last_collapsed_at_time_obj.last_collapsed_at_time
    else
      last_collapsed_at_time = DateTime.new(1990,01,01);
    end
    
    latest_notice_id_obj = Admin::SiteNoticeRole.where(:role_id => all_roles_of_user)
    if(!latest_notice_id_obj.nil?)
      latest_notice_id_obj.each do |notice|
        all_notices_ids <<  notice.notice_id
      end
      latest_notice_at_time = Admin::SiteNotice.where(:id => all_notices_ids).maximum("updated_at")
    end
    
    @all_notices_to_render = Array.new
    
    
    @NOTICE_DISPLAY_TYPES = {
      :no_notice => 1,
      :new_notices => 2,
      :collapsed_notices => 3
    }
    
    if(latest_notice_id_obj.nil?)
      @notice_display_type = @NOTICE_DISPLAY_TYPES[:no_notice]
    elsif ( (last_collapsed_at_time_obj.nil?) ? true : (last_collapsed_at_time < latest_notice_at_time) )
      @notice_display_type = @NOTICE_DISPLAY_TYPES[:new_notices]
      flag = 0
      all_notices_ids = all_notices_ids.uniq
      all_notices = Admin::SiteNotice.where(:id => all_notices_ids)
      dismissed_notices = Admin::SiteNoticeUser.find_all_by_user_id(current_user.id)
      if(!dismissed_notices.nil?)
        all_notices.each do |notice|
          dismissed_notices.each do |dismissed|
            if dismissed.notice_id == notice.id 
              flag = 1
            end  
          end
          if(flag == 0)
            @all_notices_to_render << notice
          else
            flag = 0          
          end  
        end
      else
        all_notices.each do |notice|
           @all_notices_to_render << notice 
        end
      end  
    elsif(last_collapsed_at_time >= latest_notice_at_time)
      @notice_display_type = @NOTICE_DISPLAY_TYPES[:collapsed_notices]
      flag = 0
      all_notices_ids = all_notices_ids.uniq
      all_notices = Admin::SiteNotice.where(:id => all_notices_ids) 
      dismissed_notices = Admin::SiteNoticeUser.find_all_by_user_id(current_user.id)
      if(!dismissed_notices.nil?)
        all_notices.each do |notice|
          dismissed_notices.each do |dismissed|
            if dismissed.notice_id == notice.id 
              flag = 1
            end  
          end
          if(flag == 0)
            @all_notices_to_render << notice
          else
            flag = 0          
          end  
        end
      else
        all_notices.each do |notice|
           @all_notices_to_render << notice 
        end
      end      
    end
    if @all_notices_to_render.length == 0
      @notice_display_type = @NOTICE_DISPLAY_TYPES[:no_notice]
    end
  end
  
  def readme
    @document = FormattedDoc.new('README.textile')
    render :action => "formatted_doc", :layout => "technical_doc"
  end

  def doc
    if document_path = params[:document].gsub(/\.\.\//, '')
      @document = FormattedDoc.new(File.join('doc', document_path))
      render :action => "formatted_doc", :layout => "technical_doc"
    end
  end

  def pick_signup
  end

  def about
  end
  
  def requirements
  end

  # view_context is a reference to the View template object
  def name_for_clipboard_data
    render :text=> view_context.clipboard_object_name(params)
  end

  def missing_installer
    @os = params['os']
  end

  def test_exception
    raise 'This is a test. This is only a test.'
  end

  def project_css
    @project = Admin::Project.default_project
    if @project.using_custom_css?
      render :text => @project.custom_css
    else
      render :nothing => true, :status => 404
    end
  end

  def report
    # two different ways to render pdfs
    respond_to do |format|
      # this method uses classes in app/pdfs to generate the pdf:
      format.html {
        output = ::HelloReport.new.to_pdf
        send_data output, :filename => "hello1.pdf", :type => "application/pdf"
      }
      # this method uses the prawn-rails gem to render the view:
      #   app/views/home/report.pdf.prawn
      # see: https://github.com/Volundr/prawn-rails
      format.pdf { render :layout => false }
    end
  end

  # def index
  #   if current_user.require_password_reset
  #     redirect_to :controller => :passwords, :action=>'reset', :reset_code => 0
  #   end
  # end
  
  def recent_activity
    if current_user.anonymous?
      redirect_to home_url
      return
    end
  
    @report_learner = Report::Learner.all
    
    teacher_clazzes = current_user.portal_teacher.clazzes;
    portal_teacher_clazzes = current_user.portal_teacher.teacher_clazzes
    portal_teacher_offerings = [];
    teacher_clazzes.each do|teacher_clazz|
      if portal_teacher_clazzes.find_by_clazz_id(teacher_clazz.id).active && teacher_clazz.students.length > 0
        portal_teacher_offerings.concat(teacher_clazz.offerings)
      end
    end
    
    strTime =(7.day.ago).to_s.gsub(" UTC","");
    learner_offerings = ((Report::Learner.where("last_run > '#{strTime}' and complete_percent > 0")).order("last_run DESC")).select(:offering_id).uniq
    
    if (learner_offerings.count == 0)
      redirect_to root_path
      return
    end
    
    @clazz_offerings=Array.new    
    
    
    learner_offerings.each do |learner_offering|
      portal_teacher_offerings.each do|teacher_offering|
        reportlearner = Report::Learner.find_by_offering_id(learner_offering.offering_id)
        if reportlearner.offering_id == teacher_offering.id
          offering = Portal::Offering.find(reportlearner.offering_id)
          if offering.inprogress_students_count > 0 || offering.completed_students_count > 0
            @clazz_offerings.push(offering)
          end
        end
      end
    end
    
    
  end
end
