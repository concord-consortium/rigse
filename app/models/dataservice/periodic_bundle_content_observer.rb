class Dataservice::PeriodicBundleContentObserver < ActiveRecord::Observer
  def after_create(bundle_content)
    bundle_content.extract_parts
    bundle_content.extract_saveables
    # bundle_content.copy_to_collaborators
  end
end
