class SakaiLinkController < ApplicationController

  def index
    @site = params[:site]
    @username = params[:username]
    @params = params
    # render views/sakai_link.html.haml
  end
end
