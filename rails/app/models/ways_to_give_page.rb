class WaysToGivePage
  def initialize(user, settings, preview_content=nil)
    @user = user
    @settings = settings
    @preview_content = preview_content
  end

  def content
    @preview_content || @settings.ways_to_give_page_content || "(No content has been set for the Ways to Give page.)"
  end

  def view_options
    {
      custom_content: content
    }
  end
end
