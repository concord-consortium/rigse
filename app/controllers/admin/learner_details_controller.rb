class Admin::LearnerDetailsController < ApplicationController

  # GET /learner_details/1
  # GET /learner_details/1.txt
  # GET /learner_details/1.json
  def show
    authorize Admin::LearnerDetails
    learner = Portal::Learner.find_by_id_or_key(params[:id_or_key])
    @learner_details = LearnerDetail.new learner
    respond_to do |format|
      format.text  { render :text => @learner_details.display }
      format.json  { render :json => @learner_details.to_json }
    end
  end
end
