class API::APIController < ApplicationController

	def error(message, status = 400)
	  # PUNDIT_REVIEW_AUTHORIZE
	  # PUNDIT_CHOOSE_AUTHORIZE
	  # no authorization needed ...
	  # authorize Api::Api
	  # authorize @api
	  # authorize Api::Api, :new_or_create?
	  # authorize @api, :update_edit_or_destroy?
	  render :json =>
	  	{
		  	:response_type => "ERROR",
		  	:message => message
	  	},
	  	:status => status
	end

	def unauthorized
	  # PUNDIT_REVIEW_AUTHORIZE
	  # PUNDIT_CHOOSE_AUTHORIZE
	  # no authorization needed ...
	  # authorize Api::Api
	  # authorize @api
	  # authorize Api::Api, :new_or_create?
	  # authorize @api, :update_edit_or_destroy?
		error("unauthorized", 401)
	end

	def show
	  # PUNDIT_REVIEW_AUTHORIZE
	  # PUNDIT_CHECK_AUTHORIZE (did not find instance)
	  # authorize @api
		error("Show not configured for this resource")
	end

	def create
	  # PUNDIT_REVIEW_AUTHORIZE
	  # PUNDIT_CHECK_AUTHORIZE
	  # authorize Api::Api
		error("create not configured for this resource")
	end

	def update
	  # PUNDIT_REVIEW_AUTHORIZE
	  # PUNDIT_CHECK_AUTHORIZE (did not find instance)
	  # authorize @api
		error("update not configured for this resource")
	end

	def index
	  # PUNDIT_REVIEW_AUTHORIZE
	  # PUNDIT_CHECK_AUTHORIZE
	  # authorize Api::Api
	  # PUNDIT_REVIEW_SCOPE
	  # PUNDIT_CHECK_SCOPE (did not find instance)
	  # @apis = policy_scope(Api::Api)
		error("index not configured for this resource")
	end

	def destroy
	  # PUNDIT_REVIEW_AUTHORIZE
	  # PUNDIT_CHECK_AUTHORIZE (did not find instance)
	  # authorize @api
		error("destroy not configured for this resource")
	end
end
