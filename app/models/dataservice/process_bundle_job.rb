class Dataservice::ProcessBundleJob < Struct.new(:bundle_content_class, :bundle_content_id)
  def perform
    bundle_content = bundle_content_class.find(bundle_content_id)
    bundle_content.delayed_process_bundle
  end
end
