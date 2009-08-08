class Portal::HomeController < ApplicationController
  
  def readme
    @readme = Portal::ReadMe.new
    render :layout => false
  end
  
end
