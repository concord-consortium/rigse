require 'json'
class Portal::OfferingsMetalController < ActionController::Metal

  def launch_status
    if (offering = Portal::Offering.find(params[:id])) && (current_user = (session[:user_id] ? User.find(session[:user_id]) : nil)) && current_user.portal_student
      learner = Portal::Learner.find_by_offering_id_and_student_id(offering.id, current_user.portal_student.id)
      status_event_info = {}
      if learner && learner.bundle_logger.in_progress_bundle
        last_event = learner.bundle_logger.in_progress_bundle.launch_process_events.last
        if last_event
          status_event_info["event_type"] = last_event.event_type.gsub(/\s+/, '_')
          status_event_info["event_details"] = last_event.event_details
        end
      else
        # no in progress bundle. use a special response to indicate there's no active session
        status_event_info = {"event_type" => "no_session", "event_details" => "There's not a current session." }
      end

      self.status = 200
      self.content_type = 'application/json'
      self.response_body = status_event_info.to_json
      self.headers['Cache-Control'] = 'no-cache, no-store, max-age=0, must-revalidate'
      self.headers['Pragma'] = 'no-cache'
      self.headers['Expires'] = 'Fri, 01 Jan 1990 00:00:00 GMT'
    else
      self.status = 404
      self.content_type = 'text/html'
      self.response_body = 'Not Found'
    end
  end
end
