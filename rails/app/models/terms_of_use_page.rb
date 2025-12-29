class TermsOfUsePage
  def initialize(user, settings, preview_content=nil)
    @user = user
    @settings = settings
    @preview_content = preview_content
  end

  def content
    @preview_content || @settings.terms_of_use_page_content || "(No content has been set for the Terms of Use page.)"
  end

  def view_options
    {
      custom_content: content
    }
  end
end
