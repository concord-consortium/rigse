# Allow the metal piece to run in isolation
require(File.dirname(__FILE__) + "/../../config/environment") unless defined?(Rails)
require 'rack/utils'

# /dataservice/bundle_loggers/7/bundle_contents.bundle

class BundleContent
  
  POST_BODY = 'rack.input'.freeze
  
  def self.call(env)
    bundle_logger_id = env["PATH_INFO"][/\/dataservice\/bundle_loggers\/(\d+)\/bundle_contents\.bundle/, 1]
    if bundle_logger_id
      bundle_logger = Dataservice::BundleLogger.find(bundle_logger_id)
      if bundle_logger
        bundle_content = bundle_logger.bundle_contents.create(:body => env[POST_BODY].read)
      end
    end
    if bundle_content
      [200, {"Content-Type" => "text/xml"}, ['Created']]
    else
      [400, {"Content-Type" => "text/xml"}, ["Bad Request"]]
    end
  end
end
