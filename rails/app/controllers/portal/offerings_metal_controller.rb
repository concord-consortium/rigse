require 'json'
class Portal::OfferingsMetalController < ActionController::Metal

  def launch_status
    if (offering = Portal::Offering.find(params[:id])) && (current_visitor=logged_in_user) && current_visitor.portal_student
      learner = Portal::Learner.find_by_offering_id_and_student_id(offering.id, current_visitor.portal_student.id)
      status_event_info = {}
      status_event_info = {"event_type" => "no_session", "event_details" => "We have no idea if there is a current session.  You have any guesses?" }

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
    return nil unless warden_id_array = warden_session[0]
    User.find(warden_id_array[0])
  end
end
