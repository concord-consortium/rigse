def will_paginate_params
  {:limit=>30, :offset=>0, :include=>{}}
end

def generate_mock_project
  @mock_project ||= mock_model(Admin::Project,
    :maven_jnlp_server => mock_model( MavenJnlp::MavenJnlpServer),
    :maven_jnlp_family => mock_model(MavenJnlp::MavenJnlpFamily,
      :update_snapshot_jnlp_url => :jnlp_url,
      :snapshot_jnlp_url => mock_model(MavenJnlp::VersionedJnlpUrl,
        :versioned_jnlp => mock_model(MavenJnlp::VersionedJnlp)
      )
    ),
    :jnlp_version_str => :jnlp_version_str,
    :snapshot_enabled => :snapshot_enabled
  )
  @mock_gui_testing_maven_jnlp_family ||= mock_model(
    MavenJnlp::MavenJnlpFamily, :update_snapshot_jnlp_url => :jnlp_url, 
      :snapshot_jnlp_url        => mock_model(MavenJnlp::VersionedJnlpUrl, :versioned_jnlp => mock_model( MavenJnlp::VersionedJnlp)),
      :update_snapshot_jnlp_url => mock_model(MavenJnlp::VersionedJnlpUrl, :versioned_jnlp => mock_model( MavenJnlp::VersionedJnlp))
  )
  MavenJnlp::MavenJnlpFamily.stub!(:find_by_name).with("gui-testing").and_return(@mock_gui_testing_maven_jnlp_family)
end

def login_admin(options = {})
  options[:admin] = true
  @logged_in_user = Factory.next :admin_user
  @controller.stub!(:current_user).and_return(@logged_in_user)
  @logged_in_user
end

def login_anonymous
  logout_user
end

def logout_user
  @logged_in_user = Factory.next :anonymous_user
  @controller.stub!(:current_user).and_return(@logged_in_user)
  @logged_in_user
end