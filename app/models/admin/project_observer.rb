class Admin::ProjectObserver < ActiveRecord::Observer
  def after_update(project)
    css_path = "#{ActionController::Base.page_cache_directory}/stylesheets/project.css"
    File.delete(css_path) if File.exists?(css_path)
  end
end
