class HomeController < ApplicationController
  
  def readme
    @readme = ReadMe.new
    render :layout => false
  end
  
end
