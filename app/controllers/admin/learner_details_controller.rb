class Admin::LearnerDetailsController < ApplicationController
  include PeerAccess

  # GET /learner_details/1
  # GET /learner_details/1.txt
  # GET /learner_details/1.json
  def show
    if verify_request_is_peer
      learner = Portal::Learner.find(params[:id])
      @learner_details = LearnerDetail.new learner
      respond_to do |format|
        format.text  { render :text => @learner_details.display }
        format.json  { render :json => @learner_details.to_json }
      end
    else
      render text: "unauthorized"
    end
  end
end
