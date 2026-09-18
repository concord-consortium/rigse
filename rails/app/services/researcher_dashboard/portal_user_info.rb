module ResearcherDashboard
  # The user information report-server needs in order to mint or revoke a researcher's
  # dashboard token.
  #
  # The portal is authoritative about all of it, and report-server's
  # `get_allowed_project_ids` branches on the three role flags, so sending them keeps
  # them current where report-server's own copy is only as fresh as that user's last
  # sign-in there, which for a researcher who only meets it through a VM may be never.
  #
  # One builder, because these values travel by two routes: signed into the launch
  # assertion the report-service function relays, and in the body of the revoke call the
  # portal makes itself.
  module PortalUserInfo
    def self.for(user)
      {
        portal_user_id: user.id,
        portal_server: URI.parse(APP_CONFIG[:site_url]).host,
        login: user.login,
        first_name: user.first_name,
        last_name: user.last_name,
        email: user.email,
        is_admin: user.has_role?('admin'),
        is_project_admin: user.admin_for_projects.any?,
        is_project_researcher: user.researcher_for_projects.any?
      }
    end
  end
end
