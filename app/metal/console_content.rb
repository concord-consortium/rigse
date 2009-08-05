# Allow the metal piece to run in isolation
require(File.dirname(__FILE__) + "/../../config/environment") unless defined?(Rails)
require 'rack/utils'

# /dataservice/console_loggers/7/console_contents.console

class ConsoleContent
  
  POST_BODY = 'rack.input'.freeze
  
  def self.call(env)
    if console_logger_id = env["PATH_INFO"][/\/dataservice\/console_loggers\/(\d+)\/console_contents\.console/, 1]
      if console_logger = Dataservice::ConsoleLogger.find(console_logger_id)
        console_content = console_logger.console_contents.create(:body => env[POST_BODY].read)
      end
    end
    if console_content
      [201, {}, []]
    else
      [404, { 'Content-Type' => 'text/html' }, ['Not Found']]
    end
  ensure
    # Release the connections back to the pool.
    # see: http://blog.codefront.net/2009/06/15/activerecord-rails-metal-too-many-connections/
    ActiveRecord::Base.clear_active_connections!      
  end
end
