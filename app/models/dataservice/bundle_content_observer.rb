class Dataservice::BundleContentObserver < ActiveRecord::Observer
  def after_create(bundle_content)
    bundle_content.extract_open_responses
  end

  def after_save(user)
    # do nothing
  end
end