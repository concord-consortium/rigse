class HomePage
  MyClasses        = "my_classes"
  GettingStarted   = "getting_started"
  RecentActivity   = "recent_activity"
  Guest            = "guest"
  LayoutUnwrapped  = "minimal"
  LayoutNormal     = "application"
  Home             = "home"

  NeedsSettings    = I18n.t('HomePage.NeedSettings')

  def initialize(user, settings, preview_content=nil)
    @user = user
    @settings = settings
    @preview_content = preview_content
  end

  def redirect
    if @settings.nil?
      NeedsSettings     # render needs settings if we do.
    elsif @user.portal_teacher
      if @user.has_active_classes?
        RecentActivity            # Should redirect in controller
      else
        GettingStarted            # Should redirect in controller
      end
    elsif @user.portal_student
      MyClasses                   # Should redirect in controller
    else
      Home
    end
  end

  def content
    @preview_content || @settings.home_page_content
  end


  def layout
    if content and wrap_home_page?
      return LayoutNormal
    end
    return LayoutUnwrapped
  end


  private
  def wrap_home_page?
    @settings.wrap_home_page_content?
  end

end