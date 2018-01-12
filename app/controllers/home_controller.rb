class HomeController < ApplicationController
  include Materials::DataHelpers

  protected

  def not_authorized_error_message
    super({resource_type: 'page'})
  end

  public

  caches_page   :settings_css
  theme "rites"

  def index
    homePage = HomePage.new(current_visitor, current_settings)
    flash.keep

    @open_graph = default_open_graph

    case homePage.redirect
      when HomePage::MyClasses
        redirect_to :my_classes
      when HomePage::Home
        load_notices
        load_featured_materials
        render :home, locals: homePage.view_options, layout: homePage.layout
      else
        redirect_to homePage.redirect
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
    @emulate_anonymous_user = true
    preview_content = params[:home_page_preview_content]
    homePage = HomePage.new(User.anonymous, Admin::Settings.default_settings, preview_content)
    @wide_content_layout = true
    load_notices
    load_featured_materials
    response.headers["X-XSS-Protection"] = "0"
    render :home, locals: homePage.view_options, layout: homePage.layout
  end

  def readme
    @document = FormattedDoc.new('README.md')
    render :action => "formatted_doc", :layout => "technical_doc"
  end

  def doc
    if document_path = params[:document].gsub(/\.\.\//, '')
      @document = FormattedDoc.new(File.join('docs', document_path))
      render :action => "formatted_doc", :layout => "technical_doc"
    end
  end

  def pick_signup
  end

  def about
    @page_title = 'About'
    @open_graph = default_open_graph
    @open_graph[:title] = "About the #{APP_CONFIG[:site_name]}"

    render layout: 'minimal'
  end

  def collections
    @page_title = 'Collections'
    @open_graph = default_open_graph
    @open_graph[:title] = @page_title
    @open_graph[:description] = %{
      Many of the Concord Consortium's educational STEM resources are part of collections
      created by our various research projects. Each collection has specific learning
      goals within the context of a larger subject area.
    }.gsub(/\s+/, " ").strip
  render layout: 'minimal'
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

    portal_teacher = current_visitor.portal_teacher
    teacher_clazzes = portal_teacher.clazzes
    portal_teacher_clazzes = portal_teacher.teacher_clazzes

    portal_teacher_offerings = [];
    portal_student_ids = []
    teacher_clazzes.each do|teacher_clazz|
      if portal_teacher_clazzes.find_by_clazz_id(teacher_clazz.id).active
        @offerings_count += teacher_clazz.teacher_visible_offerings.count

        students = teacher_clazz.students
        portal_student_ids.concat(students.map{|s| s.id})
        student_count = students.count
        @student_count += student_count
        if student_count > 0
          portal_teacher_offerings.concat(teacher_clazz.teacher_visible_offerings)
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


  #
  #
  # Handle /stem-reources/ routes to either pre-populate stem finder filters
  # or render an individual material resource lightbox.
  #
  #
  def stem_resources

    # logger.info("INFO stem_resources")

    if ! params[:id]
      case params[:type]
      when "activity", "sequence"

        # logger.info("INFO loading external_activity")

        @lightbox_resource = ExternalActivity.find_by_id(params[:id_or_filter_value])
        if @lightbox_resource
            id = @lightbox_resource.id
        end

      when "interactive"

        interactive = Interactive.find_by_id(params[:id_or_filter_value])

        if interactive && interactive.respond_to?(:external_activity_id)
            id = interactive.external_activity_id
            @lightbox_resource = ExternalActivity.find_by_id(id)
        end

      else
        #
        # Otherwise assume the type is referring to a filter name.
        # And in this case the id_or_filter_value is a filter value.
        #
        index
        return
      end

      #
      # If id is non nil, redirect to valid resource.
      #
      if ! id.nil?

        #
        # Get slug to append to redirect url
        #
        slug = nil
        if    @lightbox_resource && 
                @lightbox_resource.name &&
                @lightbox_resource.name.respond_to?(:parameterize)
    
            slug = @lightbox_resource.name.parameterize
    
        end
    
        # logger.info("INFO redirecting for #{id}")
    
        #
        # Redirect to external_activity under /resource/:id/:slug
        #
        redirect_to view_context.stem_resources_url(id, slug)
        return

      end

    end

    # logger.info("INFO loading #{params[:id]}")

    external_activity_id = params[:id]
    @lightbox_resource = ExternalActivity.find_by_id(external_activity_id)

    # logger.info("INFO found lightbox_resource #{@lightbox_resource}")

    #
    # Check that user has permission to view the resource.
    #
    if  @lightbox_resource                                      &&
        @lightbox_resource.respond_to?(:publication_status)     &&
        @lightbox_resource.publication_status != 'published'

        if current_user.nil?
            #
            # Block anonymous user.
            #
            @lightbox_resource = nil
        else
            #
            # For logged in user, block if user is not either resource owner
            # or admin.
            #
            if ! (current_user.id == @lightbox_resource.user_id || current_user.has_role?('admin'))
                @lightbox_resource = nil
            end
        end
    end

    if @lightbox_resource
      @lightbox_resource = materials_data([@lightbox_resource], nil, 4).shift()
      @page_title = @lightbox_resource[:name]
      @resource_icon = @lightbox_resource[:icon]
      @open_graph = {
        title: @page_title,
        description: @lightbox_resource[:description] ||
          "Check out this educational resource from the Concord Consortium.",
        image: @resource_icon[:url] ||
          "https://learn-resources.concord.org/images/stem-resources/stem-resource-finder.jpg"
      }
    else
      @page_title = "Resource not found"
    end
    @auto_show_lightbox_resource = true

    homePage = HomePage.new(current_visitor, current_settings)
    load_notices
    load_featured_materials
    render :home, locals: homePage.view_options, layout: homePage.layout, status: @lightbox_resource.nil? ? 404: 200
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

  def default_open_graph
    open_graph = {}
    if ENV['OG_TITLE']
      open_graph[:title] = ENV['OG_TITLE']
    end
    if ENV['OG_DESCRIPTION']
      open_graph[:description] = ENV['OG_DESCRIPTION']
    end
    if ENV['OG_IMAGE_URL']
      open_graph[:image] = ENV['OG_IMAGE_URL']
    end
    open_graph
  end
end
