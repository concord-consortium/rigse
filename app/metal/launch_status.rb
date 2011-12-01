# Allow the metal piece to run in isolation
require(File.dirname(__FILE__) + "/../../config/environment") unless defined?(Rails)
require 'json'
# /portal/offerings/7/launch_status.json

class LaunchStatus
  
  REQUEST_METHOD = 'REQUEST_METHOD'.freeze unless defined?(REQUEST_METHOD)
  GET = 'GET'.freeze unless defined?(GET)
  PATH_INFO = 'PATH_INFO'.freeze unless defined?(PATH_INFO)
  
  
  def self.call(env)
    # uncomment this line to let the portal/offerings controller handle this post
    # return [404, { 'Content-Type' => 'text/html' }, ['Not Found']]

    session = env["rack.session"]
    offering_id = env[PATH_INFO][/\/portal\/offerings\/(\d+)\/launch_status\.json/, 1]
    if env[REQUEST_METHOD] == GET && offering_id && offering = ::Portal::Offering.find(offering_id)
      current_user = session[:user_id] ? User.find(session[:user_id]) : nil
      if current_user && current_user.portal_student
        learner = Portal::Learner.find_by_offering_id_and_student_id(offering.id, current_user.portal_student.id)
        status_event_info = {}
        if learner && learner.bundle_logger.in_progress_bundle
          last_event = learner.bundle_logger.in_progress_bundle.launch_process_events.last
          if last_event
            status_event_info["event_type"] = last_event.event_type
            status_event_info["event_details"] = last_event.event_details
          end
        else
          # no in progress bundle. use a special response to indicate there's no active session
          status_event_info = {"event_type" => "no_session", "event_details" => "There's not a current session." }
        end
        return [200, 
          { 'Content-Type' => 'application/json' }, 
          [status_event_info.to_json]
        ]
      end
    end
    return [404, { 'Content-Type' => 'text/html' }, ['Not Found']]
  ensure
    # If we accessed ActiveRecord then release the connections back to the pool. 
    # see: http://blog.codefront.net/2009/06/15/activerecord-rails-metal-too-many-connections/
    ActiveRecord::Base.clear_active_connections! if offering_id
  end
end
