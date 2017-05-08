class Reports::UrlHelpers
  def initialize(opts = {})
    @protocol = opts[:protocol]
    @host_with_port = opts[:host_with_port]
  end

  def remote_endpoint_url(portal_learner)
    portal_learner.remote_endpoint_url
  end
end
