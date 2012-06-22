module JnlpLaunchable
  def run_format
    USING_JNLPS ? :jnlp : :run_html
  end
end
