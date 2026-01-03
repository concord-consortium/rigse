class TeacherGuidePage
  def initialize(user, settings, preview_content=nil)
    @user = user
    @settings = settings
    @preview_content = preview_content
  end

  def content
    @preview_content || @settings.teacher_guide_page_content || "(No content has been set for the Teacher Guide page.)"
  end

  def external_url
    @settings.teacher_guide_external_url
  end

  def view_options
    {
      custom_content: content
    }
  end
end
