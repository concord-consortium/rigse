class Dataservice::ExternalActivityDataController < ApplicationController

  private
  def can_create(learner)
    # allow admins and managers to re-post learner data
    # from LARA
    return true if (current_visitor.has_role? "admin")
    return true if (current_visitor.has_role? "manager")
    return true if (current_visitor == learner.user )
    raise ActionController::RoutingError.new('Not Allowed')
  end

  public
  def create
    learner_id = params[:id]
    if learner = Portal::Learner.find(learner_id)
      if can_create(learner)
        # add CORS support only from the domain that is the the location of the activity
        # Note: all this does is eliminate an error message that would show up in the browser
        # without it. It doesn't actually add any more security.
        # If request forgery protection was properly turned on, then we shouldn't even get
        # to this point for a normal request. In that case requests of the types:
        # text/plain, multipart/form-data, or application/x-www-form-urlencoded
        # should be forced to contain the CSRP token and otherwise they are blocked.
        # requests that aren't that type should be pre-flighted with an OPTIONS request by
        # the browser. This OPTIONS request should give us the oportunity to block the request
        url = URI.parse(learner.offering.runnable.url)
        host_with_port = url.port ? "#{url.host}:#{url.port}" : url.host
        headers['Access-Control-Allow-Origin'] = "#{url.scheme}://#{host_with_port}"
        headers['Access-Control-Allow-Methods'] = 'POST, GET, OPTIONS'
        headers['Access-Control-Allow-Credentials'] = 'true'
        headers['Access-Control-Max-Age'] = '1728000'

        # To handle a preflighted request, the routing code probably needs to be updated to support 
        # this options method
        # if request.method == :options
        #   render :text => '', :content_type => 'text/plain'
        # end

        # It is tempting to add something like the CSRF token to requests here.
        # It would need to be passed to the browser-activity through the URL when it is launched.
        # However this means the token is in the url which means if someone copied the URL and
        # emailed it, then this token would be public. It also would be public when a user goes
        # to another page so then the token would sent to the other site through a referrer header
        # So we can't really do this. Therefore we need to rely on the browsers security. 
        # In that case we can check the 'origin' header and/or we can force preflighting the request
        # by turning back on CSRF protection.

        Delayed::Job.enqueue Dataservice::ProcessExternalActivityDataJob.new(learner_id, request.body.read)
        render :status => 201, :nothing => true
        return
      end
    end
    raise ActionController::RoutingError.new('Not Found')
  end

end
