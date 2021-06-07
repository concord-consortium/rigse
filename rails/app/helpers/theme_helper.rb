
module ThemeHelper
  DEFAULT_THEME = 'learn'.freeze
  ENV_THEME_KEY = 'THEME'.freeze
  THEME_BODY_SUFFIX = "-theme-styles"
  def theme_name
    ENV[ENV_THEME_KEY].blank? ? DEFAULT_THEME : ENV[ENV_THEME_KEY]
  end

  def themed_body_class
    "#{theme_name}#{THEME_BODY_SUFFIX}"
  end

  def render_themed_partial(partial)
    partial_path = "themes/#{theme_name}/#{partial}"
    if lookup_context.template_exists?(partial_path, [], true)
      render partial: partial_path
    else
      render partial: partial
    end
  end

end
