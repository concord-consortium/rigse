class API::V1::SecurityQuestionsController < API::APIController

	def index
	  # PUNDIT_REVIEW_AUTHORIZE
	  # PUNDIT_CHECK_AUTHORIZE
	  # authorize Api::V1::SecurityQuestion
	  # PUNDIT_REVIEW_SCOPE
	  # PUNDIT_CHECK_SCOPE (did not find instance)
	  # @security_questions = policy_scope(Api::V1::SecurityQuestion)
		@questions = SecurityQuestion::QUESTIONS
		render :json => @questions
	end

end
