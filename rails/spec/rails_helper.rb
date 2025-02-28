require "devise"
require File.expand_path('../config/environment', __dir__)

RSpec.configure do |config|
  config.before(:each) do
    Rails.application.routes.default_url_options[:host] = 'http://test.host'
  end
  config.include Rails.application.routes.url_helpers
end
