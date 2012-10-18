class HelpController < ApplicationController
  caches_page   :project_css
  theme "rites"
  
  def index
    @help_page_content = current_project.custom_help_page_html
  end
  def preview_help_page
    @help_page_preview_content = params[:preview_help_page_content]
  end
end