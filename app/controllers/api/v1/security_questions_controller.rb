class API::V1::SecurityQuestionsController < API::APIController

	def index
		@questions = SecurityQuestion::QUESTIONS
		render :json => @questions
	end

end