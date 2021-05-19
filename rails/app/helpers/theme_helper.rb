
module ThemeHelper
  DEFAULT_THEME = 'learn'.freeze
  ENV_THEME_KEY = 'THEME'.freeze

  def theme_name
    ENV[ENV_THEME_KEY].blank? ? DEFAULT_THEME : ENV[ENV_THEME_KEY]
  end

  def themed_style_sheet_tag(name='all', media='screen, presentation')
    # see https://github.com/chamnap/themes_on_rails_example/blob/master/rails_4_1/app/themes/red/views/layouts/red.html.erb#L5
    # TODO: RAILS6 FIXME: After getting tests to pass, return to theme_for_rails work.
    # stylesheet_link_tag "#{theme_name}/#{name}", { 'media' => media }
  end

  def render_themed_partial(partial)
    partial_path = "themes/#{theme_name}/#{partial}"
    render partial: partial_path
  end

end
