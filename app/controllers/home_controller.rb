class HomeController < ApplicationController
  
  def readme
    @readme = ReadMe.new
    render :layout => false
  end
  
  def pick_signup    
  end
  
  def about
  end
  
end
