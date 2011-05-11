##### example .capybara.rb

# for firefox when app is running on vagrant
# selenium_remote :url => "http://10.0.2.2:4444/wd/hub",
#     :desired_capabilities => Selenium::WebDriver::Remote::Capabilities.firefox
# server_host "33.33.33.10" 

# for IE on saucelabs using sauce_connect
# Capybara.server_port = 3001
# Capybara.app_host = "http://example.com:#{Capybara.server_port}"
# selenium_remote :url => "http://[sauce-user]:[sauce-key]@ndemand.saucelabs.com:80/wd/hub"
#     :desired_capabilities => Selenium::WebDriver::Remote::Capabilities.internet_explorer
# the sauce_connect command would look like:
# sauce_connect -u [sauce-user] -k [sauce-key] -s 33.33.33.10 -p 3001 -d example.com

require 'selenium-webdriver'

class CapybaraConfig
  class << self
    attr_accessor :server_host
  end
  
  def selenium(options)
    Capybara.register_driver :selenium do |app|
      Capybara::Driver::Selenium.new(app, options)      
    end
  end

  def selenium_remote(options)
    options[:browser] = :remote
    selenium(options)
  end

  def server_host(host)
    CapybaraConfig.server_host = host
  end
end

class Capybara::Server
  def host
    CapybaraConfig.server_host || "127.0.0.1"
  end
end  

settings_file = File.expand_path("~/.capybara.rb")
if File.exists?(settings_file)
  CapybaraConfig.new.instance_eval(IO.read(settings_file), settings_file)
end