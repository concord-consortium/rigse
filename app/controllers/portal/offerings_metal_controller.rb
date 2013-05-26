require 'json'
class Portal::OfferingsMetalController < ActionController::Metal

  def launch_status
    if (offering = Portal::Offering.find(params[:id])) && (current_visitor=logged_in_user) && current_visitor.portal_student
      learner = Portal::Learner.find_by_offering_id_and_student_id(offering.id, current_visitor.portal_student.id)
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
      NoCache.add_headers(self.headers)
    else
      self.status = 404
      self.content_type = 'text/html'
      self.response_body = 'Not Found'
    end
  end

  private

  def logged_in_user
    return nil unless warden_session = session['warden.user.user.key']
    return nil unless warden_id_array = warden_session[1]
    User.find(warden_id_array[0])
  end
end
