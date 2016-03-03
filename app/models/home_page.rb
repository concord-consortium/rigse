class HomePage
  MyClasses        = "my_classes"
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
    if @user.portal_teacher and @settings.teacher_home_path.present?
      @settings.teacher_home_path
    elsif @user.portal_student
      MyClasses
    else
      Home
    end
  end

  def content
    if @settings.nil?
      NeedsSettings
    else
      @preview_content || @settings.home_page_content
    end
  end

  def view_options
    {
      custom_content: content,
      show_signup: @user.anonymous? && wrapped_page?,
      show_project_cards: wrapped_page?,
      show_featured: wrapped_page?
    }
  end

  def layout
    if wrapped_page?
      LayoutNormal
    else
      LayoutUnwrapped
    end
  end


  private
  def wrapped_page?
    content.blank? or @settings.wrap_home_page_content?
  end

  def unwrapped_page?
    content.present? and not @settings.wrap_home_page_content?
  end

end