class Admin::LearnerDetailsController < ApplicationController

  # GET /learner_details/1
  # GET /learner_details/1.txt
  # GET /learner_details/1.json
  #
  # This endpoint was only used by LARA's remote_info action (peer-to-peer auth).
  # That caller is confirmed dead (zero traffic over 365 days). The policy now
  # returns false, so this action always 403s. Safe to delete in a future cleanup.
  def show
    authorize LearnerDetail
    learner = Portal::Learner.find_by_id_or_key(params[:id_or_key])
    @learner_details = LearnerDetail.new learner
    respond_to do |format|
      format.text  { render :plain => @learner_details.display }
      format.json  { render :json => @learner_details.to_json }
    end
  end
end
