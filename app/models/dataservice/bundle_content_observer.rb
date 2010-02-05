class Dataservice::BundleContentObserver < ActiveRecord::Observer
  def after_create(bundle_content)
    bundle_content.extract_saveables
  end

  def after_save(user)
    # do nothing
  end
end