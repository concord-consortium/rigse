class Dataservice::BundleContentObserver < ActiveRecord::Observer
  def after_create(bundle_content)
    # first schedule the bundle processing
    cmd = "nice #{RAILS_ROOT}/script/runner 'Dataservice::BundleContent.find(#{bundle_content.id}).extract_saveables'"
    jobs = ::Bj.submit cmd, :tag => 'bundle_content_processing'
  end

  def after_save(user)
    # do nothing
  end
end