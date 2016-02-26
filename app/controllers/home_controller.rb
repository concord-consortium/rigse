class HomeController < ApplicationController

  rescue_from Pundit::NotAuthorizedError, with: :pundit_user_not_authorized

  private

  def pundit_user_not_authorized(exception)
    if exception.query.to_s == 'admin?'
      flash[:notice] = "Please log in as an administrator"
    end
    redirect_to :root
  end

  public

  caches_page   :settings_css
  theme "rites"

  def index
    homePage = HomePage.new(current_visitor, Admin::Settings.default_settings)
    flash.keep
    case homePage.redirect
      when HomePage::MyClasses
        redirect_to :my_classes
      when HomePage::RecentActivity
        redirect_to :recent_activity
      when HomePage::GettingStarted
        redirect_to :getting_started
      when HomePage::Home
        redirect_to :home
    end
  end

  def home
    homePage = HomePage.new(current_visitor, Admin::Settings.default_settings)
    custom_content = homePage.content
    load_notices
    load_featured_materials
    if custom_content.present?
      render inline: custom_content.html_safe, layout: homePage.layout
    else
      render :home
    end
  end

  def getting_started
    @hide_signup_link = true
    load_notices
    render :getting_started
  end

  def my_classes
    load_notices
    @portal_student = current_visitor.portal_student
    @hide_signup_link = true
    render :my_classes
  end

  def preview_home_page
    preview_content = params[:home_page_preview_content]
    homePage = HomePage.new(User.anonymous, Admin::Settings.default_settings, preview_content)
    @wide_content_layout = true
    load_featured_materials
    response.headers["X-XSS-Protection"] = "0"
    render inline: homePage.content.html_safe, layout: homePage.layout
  end

  def readme
    @document = FormattedDoc.new('README.md')
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

  def admin
    authorize :home, :admin?
  end

  def authoring
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

  def settings_css
    @settings = Admin::Settings.default_settings
    if @settings.using_custom_css?
      render :text => @settings.custom_css
    else
      render :nothing => true, :status => 404
    end
  end

  def report
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
  #   if current_visitor.require_password_reset
  #     redirect_to :controller => :passwords, :action=>'reset', :reset_code => 0
  #   end
  # end

  def recent_activity
    authorize :home, :recent_activity?

    notices_hash = Admin::SiteNotice.get_notices_for_user(current_visitor)
    @notices = notices_hash[:notices]
    @notice_display_type = notices_hash[:notice_display_type]

    @clazz_offerings=Array.new

    @recent_activity_msgs = {
      :no_offerings => "#{t('recent_activity.no_offerings')}<br>#{t('recent_activity.no_activity')}",
      :no_students => "#{t('recent_activity.no_students')}<br>#{t('recent_activity.no_activity')}",
      :no_activity => t('recent_activity.no_activity')
    }
    @no_recent_activity_msg = nil
    @offerings_count = 0
    @student_count = 0

    # # If there are no active classes assigned then return to the home page
    # if (!current_visitor.has_active_classes?)
    #   redirect_to root_path
    #   return
    # end

    portal_teacher = current_visitor.portal_teacher
    teacher_clazzes = portal_teacher.clazzes
    portal_teacher_clazzes = portal_teacher.teacher_clazzes

    portal_teacher_offerings = [];
    portal_student_ids = []
    teacher_clazzes.each do|teacher_clazz|
      if portal_teacher_clazzes.find_by_clazz_id(teacher_clazz.id).active
        @offerings_count += teacher_clazz.offerings.count

        students = teacher_clazz.students
        portal_student_ids.concat(students.map{|s| s.id})
        student_count = students.count
        @student_count += student_count
        if student_count > 0
          portal_teacher_offerings.concat(teacher_clazz.offerings)
        end
      end
    end


    if @offerings_count == 0
      @no_recent_activity_msg = @recent_activity_msgs[:no_offerings]
      return
    elsif @student_count == 0
      @no_recent_activity_msg = @recent_activity_msgs[:no_students]
      return
    end


    learner_offerings = (Report::Learner.where("complete_percent > 0").where(:offering_id => portal_teacher_offerings.map{|o| o.id }, :student_id => portal_student_ids).order("last_run DESC")).select(:offering_id).uniq

    if (learner_offerings.count == 0)
      # There are no report learners for this filter
      @no_recent_activity_msg = @recent_activity_msgs[:no_activity]
      return
    end


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


    if (@clazz_offerings.count == 0)
      @no_recent_activity_msg = @recent_activity_msgs[:no_activity]
      return
    end

  end



  protected

  def load_notices
    notices_hash = Admin::SiteNotice.get_notices_for_user(current_visitor)
    @notices = notices_hash[:notices]
    @notice_display_type = notices_hash[:notice_display_type]
  end

  def load_featured_materials
    @show_featured_materials = true
  end
end
