class Dataservice::LaunchProcessEvent < ActiveRecord::Base
  self.table_name = :dataservice_launch_process_events

  belongs_to :bundle_content, :class_name => "Dataservice::BundleContent", :foreign_key => "bundle_content_id"

  TYPES = {
    :session_started => "session started",
    :jnlp_requested => "jnlp requested",
    :logo_image_requested => "logo image requested",
    :config_requested => "config requested",
    :bundle_requested => "bundle requested",
    :activity_otml_requested => "activity otml requested",
    :bundle_saved => "bundle saved"
  }
end
