class HomeController < ApplicationController
  def readme
    @readme = ReadMe.new
    render :action => "readme", :layout => "readme"
  end

  def pick_signup
  end

  def about
  end

  # @template is a reference to the View template object
  def name_for_clipboard_data
    render :text=> @template.clipboard_object_name(params)
  end

  def missing_installer
    @os = params['os']
  end
end
