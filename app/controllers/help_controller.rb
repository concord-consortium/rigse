require 'iconv'

class HelpController < ApplicationController
  caches_page   :project_css
  theme "rites"
  
  def index
    @help_page_content = current_project.custom_help_page_html
    # Turn untrusted string to UTF-8. We need to do this
    # because for some reason the code being taken is an ascii
    # string being treated as UTF-8.
    # Code taken from http://stackoverflow.com/a/968618
    ic = Iconv.new('UTF-8//IGNORE', 'UTF-8')
    @help_page_content = ic.iconv(@help_page_content + ' ')[0..-2]
  end
  
  def preview_help_page
    @help_page_preview_content = params[:preview_help_page_content]
    # Turn untrusted string to UTF-8. We need to do this
    # because for some reason the code being taken is an ascii
    # string being treated as UTF-8.
    # Code taken from http://stackoverflow.com/a/968618
    ic = Iconv.new('UTF-8//IGNORE', 'UTF-8')
    @help_page_preview_content = ic.iconv(@help_page_preview_content + ' ')[0..-2]
  end
end