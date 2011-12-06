class HomeController < ApplicationController
  caches_page   :project_css
  def readme
    @document = FormattedDoc.new('README.textile')
    render :action => "formatted_doc", :layout => "technical_doc"
  end

  def doc
    if document_path = params[:document]
      @document = FormattedDoc.new(File.join('doc', File.basename(document_path)))
      render :action => "formatted_doc", :layout => "technical_doc"
    end
  end

  def pick_signup
  end

  def about
  end
  
  def requirements
  end

  def banner
    learner = (params[:learner_id] ? Portal::Learner.find(params[:learner_id]) : nil)
    if learner && learner.bundle_logger.in_progress_bundle
      launch_event = Dataservice::LaunchProcessEvent.create(
        :event_type => Dataservice::LaunchProcessEvent::TYPES[:logo_image_requested],
        :event_details => "Activity launch started. Waiting for configuration...",
        :bundle_content => learner.bundle_logger.in_progress_bundle
      )
    end
    image_folder = File.join(RAILS_ROOT, "public","images","new","banners")
    image_file = File.exists?(theme_file = File.join(image_folder, "#{APP_CONFIG[:theme]}.png")) ? theme_file : File.join(image_folder, "empty.png")
    send_file(image_file, {:type => 'image/png', :disposition => 'inline'} )
  end

  # @template is a reference to the View template object
  def name_for_clipboard_data
    render :text=> @template.clipboard_object_name(params)
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

  # def index
  #   if current_user.require_password_reset
  #     redirect_to :controller => :passwords, :action=>'reset', :reset_code => 0
  #   end
  # end
end
