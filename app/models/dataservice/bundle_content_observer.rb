class Dataservice::BundleContentObserver < ActiveRecord::Observer

  def process_saveables(bundle_content)
    if JRUBY
      bundle_content.extract_saveables
    else
      # first schedule the bundle processing
      cmd = "::Dataservice::BundleContent.find(#{bundle_content.id}).extract_saveables"
      jobs = ::Bj.submit cmd, :tag => 'bundle_content_processing'
    end
  end
  
  def copy_to_collaborators(bundle_content)
    if JRUBY
      bundle_content.copy_to_collaborators
    else
      # first schedule the bundle processing
      cmd = "::Dataservice::BundleContent.find(#{bundle_content.id}).copy_to_collaborators"
      jobs = ::Bj.submit cmd, :tag => 'bundle_copying_collaborators'
    end
  end

  def after_create(bundle_content)
    #process_saveables(bundle_content)
  end

  def after_save(bundle_content)
    process_saveables(bundle_content)
    copy_to_collaborators(bundle_content)
  end
end
