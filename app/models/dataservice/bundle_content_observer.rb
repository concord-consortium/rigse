class Dataservice::BundleContentObserver < ActiveRecord::Observer
  def after_create(bundle_content)
    if JRUBY
      bundle_content.extract_saveables
    else
      # first schedule the bundle processing
      cmd = "::Dataservice::BundleContent.find(#{bundle_content.id}).extract_saveables"
      jobs = ::Bj.submit cmd, :tag => 'bundle_content_processing'
    end
  end

  def after_save(user)
    # do nothing
  end
end