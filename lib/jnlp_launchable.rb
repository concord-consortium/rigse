module JnlpLaunchable
  def run_format
    APP_CONFIG[:use_jnlps] ? :jnlp : :run_html
  end
end
