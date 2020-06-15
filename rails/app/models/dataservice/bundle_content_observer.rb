class Dataservice::BundleContentObserver < ActiveRecord::Observer
  def after_create(bundle_content)
    #bundle_content.extract_saveables
  end

  def after_save(bundle_content)
    # there will be no saveables to extract, and no need to copy things if the bundle_content is empty
    unless bundle_content.otml_empty?
      Delayed::Job.enqueue Dataservice::ProcessBundleJob.new(Dataservice::BundleContent, bundle_content.id)
    end
  end
end
