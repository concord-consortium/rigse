class Dataservice::PeriodicBundleContentObserver < ActiveRecord::Observer

  def after_create(bundle_content)
    unless bundle_content.empty?
      Delayed::Job.enqueue Dataservice::ProcessBundleJob.new(Dataservice::PeriodicBundleContent, bundle_content.id)
    end
  end
end
