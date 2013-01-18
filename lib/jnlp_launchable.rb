module JnlpLaunchable
  def run_format
    APP_CONFIG[:use_jnlps] ? :jnlp : :run_html
  end

  def has_update_status?
    run_format == :jnlp
  end
end
