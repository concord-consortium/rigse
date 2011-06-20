class Admin::ProjectObserver < ActiveRecord::Observer
  def before_update(project)
    if project.custom_css_changed?
      css_path = "#{ActionController::Base.page_cache_directory}/stylesheets/project.css"
      File.delete(css_path) if File.exists?(css_path)
    end
    if project.use_bitmap_snapshots_changed? 
      investigations_path = File.join(ActionController::Base.page_cache_directory, "investigations")
      cached_files = File.join(investigations_path,"*.otml")
      Dir.glob(cached_files).each do |otml_file|
        File.delete(otml_file) if File.exists?(otml_file)
      end
    end
  end
end
