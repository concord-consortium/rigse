class HomeController < ApplicationController
  
  after_filter :store_location
  
  def readme
    @readme = ReadMe.new
    render :layout => false
  end
  
  def pick_signup    
  end
end
