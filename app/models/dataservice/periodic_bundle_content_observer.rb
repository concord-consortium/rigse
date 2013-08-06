class Dataservice::PeriodicBundleContentObserver < ActiveRecord::Observer

  def after_create(bundle_content)
    unless bundle_content.empty?
      cmd = "::Dataservice::ProcessBundleJob.new(::Dataservice::PeriodicBundleContent, #{bundle_content.id}).perform"
      ::Bj.submit cmd, :tag => 'bundle_content_processing'
    end
  end

  def after_save(bundle_content)
  end
end
