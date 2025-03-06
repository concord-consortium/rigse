require "devise"
require "factory_bot_rails"
require File.expand_path('../config/environment', __dir__)

RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods

  config.before(:each) do
    Rails.application.routes.default_url_options[:host] = 'http://test.host'
  end

  config.before(:suite) do
    FactoryBot.definition_file_paths = [Rails.root.join('spec', 'factories').to_s]
    FactoryBot.reload
  end

  config.include Rails.application.routes.url_helpers
end