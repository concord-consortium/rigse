# Allow the metal piece to run in isolation
require(File.dirname(__FILE__) + "/../../config/environment") unless defined?(Rails)

# /dataservice/console_loggers/7/console_contents.console

class ConsoleContent
  REQUEST_METHOD = 'REQUEST_METHOD'.freeze unless defined?(REQUEST_METHOD)
  POST = 'POST'.freeze unless defined?(POST)
  
  PATH_INFO = 'PATH_INFO'.freeze unless defined?(PATH_INFO)
  POST_BODY = 'rack.input'.freeze unless defined?(POST_BODY)
  
  def self.call(env)
    console_logger_id = env[PATH_INFO][/\/dataservice\/console_loggers\/(\d+)\/console_contents\.bundle/, 1]
    if env[REQUEST_METHOD] == POST && console_logger_id && console_logger = ::Dataservice::ConsoleLogger.find(console_logger_id)
      console_content = console_logger.console_contents.create(:body => env[POST_BODY].read)
    end
    if console_content
      digest = Digest::MD5.hexdigest(console_content.body)
      [201, 
        { 'Content-Type' => 'text/xml', 
          'Last-Modified' => console_content.created_at.httpdate, 
          'Content-Length' => '0',
          'Content-MD5' => digest },
        []
      ]
    else
      [404, { 'Content-Type' => 'text/html' }, ['Not Found']]
    end
  ensure
    # If we accessed ActiveRecord then release the connections back to the pool. 
    # see: http://blog.codefront.net/2009/06/15/activerecord-rails-metal-too-many-connections/
    ActiveRecord::Base.clear_active_connections! if console_logger_id
  end
end
