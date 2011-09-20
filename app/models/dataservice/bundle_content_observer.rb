class Dataservice::BundleContentObserver < ActiveRecord::Observer
  def after_create(bundle_content)
    #bundle_content.extract_saveables
  end

  def after_save(bundle_content)
    bundle_content.extract_saveables
    bundle_content.copy_to_collaborators
  end
end
