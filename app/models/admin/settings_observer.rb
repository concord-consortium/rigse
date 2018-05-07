class Admin::SettingsObserver < ActiveRecord::Observer
  def before_update(settings)
    if settings.custom_css_changed?
      # this file is created by caching a specific route
      # match '/stylesheets/settings.css' => 'home#settings_css', :as => :settings_css
      css_path = "#{ActionController::Base.page_cache_directory}/stylesheets/settings.css"
      File.delete(css_path) if File.exists?(css_path)
    end
  end
end
