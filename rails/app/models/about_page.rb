class AboutPage
  MyClasses        = "my_classes"
  About             = "about"

  NeedsSettings    = I18n.t('AboutPage.NeedSettings')

  def initialize(user, settings, preview_content=nil)
    @user = user
    @settings = settings
    @preview_content = preview_content
  end

  def content
    if @settings.nil?
      NeedsSettings
    else
      @preview_content || @settings.about_page_content
    end
  end

  def view_options
    {
      custom_content: content
    }
  end

end
