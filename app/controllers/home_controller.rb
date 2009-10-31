class HomeController < ApplicationController
  
  def readme
    @readme = ReadMe.new
    render :action => "readme", :layout => "readme"
  end
  
  def pick_signup    
  end
  
  def about
  end
  
end
