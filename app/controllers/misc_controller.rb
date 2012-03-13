class MiscController < ActionController::Base
  # This controller is intended for things that don't need all of the
  # complex setup that happens in ApplicationController. If you have
  # actions that don't need things like authentication, current_user,
  # etc. then you can place them here and they will execute more
  # quickly.
  # Also notably, nothing in the chain before this accesses session[],
  # so if a session does not already exist *it will not be created*
  # unless you action accesses session[].

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

  def installer_report
    body = request.body.read
    remote_ip = request.env['HTTP_X_FORWARDED_FOR'] || request.remote_ip
    success = !!(body =~ /Succeeded! Saved and loaded jar./)
    report = InstallerReport.create(:body => body, :remote_ip => remote_ip, :success => success)
    render :xml => "<created/>", :status => :created
  end
end
