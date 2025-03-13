require 'capybara-screenshot/rspec'

module SuppressRailsScreenshotDisplay
  def display_image(_file_name)
    # Do nothing, so it doesn't call `image_path` which causes an error.
  end
end

Capybara::Screenshot.register_driver(:headless_chrome) do |driver, path|
  driver.save_screenshot(path)
end

RSpec.configure do |config|
  config.before(:each, type: :system) do
    driven_by :headless_chrome
  end
  config.include SuppressRailsScreenshotDisplay, type: :system
end
