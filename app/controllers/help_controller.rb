require 'iconv'

class HelpController < ApplicationController
  caches_page   :project_css
  theme "rites"
  
  def index
    case current_project.help_type
    when 'no help'
      redirect_to :root
    when 'external url'
      external_url = current_project.external_url
      redirect_to "#{external_url}"
    when 'help custom html'
      @help_page_content = current_project.custom_help_page_html
      # Turn untrusted string to UTF-8. We need to do this
      # because for some reason the code being taken is an ascii
      # string being treated as UTF-8.
      # Code taken from http://stackoverflow.com/a/968618
      ic = Iconv.new('UTF-8//IGNORE', 'UTF-8')
      @help_page_content = ic.iconv(@help_page_content + ' ')[0..-2]
    end
  end
  
  def preview_help_page
    response.headers["X-XSS-Protection"] = "0"
    @help_page_preview_content = params[:preview_help_page_content]
    # Turn untrusted string to UTF-8. We need to do this
    # because for some reason the code being taken is an ascii
    # string being treated as UTF-8.
    # Code taken from http://stackoverflow.com/a/968618
    ic = Iconv.new('UTF-8//IGNORE', 'UTF-8')
    @help_page_preview_content = ic.iconv(@help_page_preview_content + ' ')[0..-2]
  end
end