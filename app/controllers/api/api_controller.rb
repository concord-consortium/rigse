class API::APIController < ApplicationController

	def error(message)
	  render :json => 
	  	{
		  	:response_type => "ERROR", 
		  	:message => message
	  	},
	  	:status => 500
	end

	def show
		error("Show not configured for this resource")
	end
	
	def create
		error("create not configured for this resource")
	end

	def update
		error("update not configured for this resource")
	end

	def index
		error("index not configured for this resource")
	end

	def destroy
		error("destroy not configured for this resource")
	end
end