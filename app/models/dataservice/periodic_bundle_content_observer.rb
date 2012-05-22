class Dataservice::PeriodicBundleContentObserver < ActiveRecord::Observer
  def after_create(bundle_content)
    bundle_content.extract_parts
    bundle_content.extract_saveables
  end
end
