def will_paginate_params
  {:limit=>30, :offset=>0, :include=>{}}
end

def mock_project
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
end

