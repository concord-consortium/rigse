class HelpController < ApplicationController
  theme "rites"

  def get_help_page(help_type)
    case help_type
    when 'no help'
      render :template => "help/no_help_page"
    when 'external url'
      external_url = current_settings.external_url
      redirect_to "#{external_url}"
    when 'help custom html'
      @help_page_content = current_settings.custom_help_page_html
    end
  end

  def index
    help_type = current_settings.help_type
    get_help_page(help_type)
  end

  def preview_help_page
    if (params[:preview_help_page_from_edit])
      response.headers["X-XSS-Protection"] = "0"
      @help_page_content = params[:preview_help_page_from_edit]
      return
    end
    @preview_help_settings_id = params[:preview_help_page_from_summary_page] || @preview_help_settings_id
    @preview_help_settings_id = @preview_help_settings_id.to_i
    preview_settings = Admin::Settings.find_by_id(@preview_help_settings_id)
    get_help_page(preview_settings.help_type)
  end
end
