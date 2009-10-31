
# In order to run the user specs the encrypted passwords
# for the 'quentin' and 'aaron' users in spec/fixtures/users.yml
# need to be created with a REST_AUTH_SITE_KEY used for testing.

REST_AUTH_SITE_KEY = 'sitekeyforrunningtests'

# Model Mocks
#
#   Admin:
#   
#     mock_admin_project
#   
#   MavenJnlp:
#   
#     mock_maven_jnlp_maven_jnlp_server
#     mock_maven_jnlp_maven_jnlp_family
#     mock_maven_jnlp_versioned_jnlp_url
#     mock_maven_jnlp_versioned_jnlp
#     mock_maven_jnlp_jar
#     mock_maven_jnlp_native_library
#     mock_maven_jnlp_icon
#     mock_maven_jnlp_property
#     mock_version_str
#   
#   OrunkExample:
#   
#     mock_otrunk_example_otrunk_view_entry
#     mock_otrunk_example_otrunk_import
#     mock_otrunk_example_otml_file
#     mock_otrunk_example_otml_category
#

def mock_admin_project
  @mock_project ||= mock_model(Admin::Project,
    :maven_jnlp_server => mock_maven_jnlp_maven_jnlp_server,
    :maven_jnlp_family => mock_maven_jnlp_maven_jnlp_family,
    :jnlp_version_str => mock_version_str,
    :snapshot_enabled => false
  )
end

def mock_maven_jnlp_maven_jnlp_server
  @maven_jnlp_server ||= mock_model( MavenJnlp::MavenJnlpServer)
end

def mock_maven_jnlp_maven_jnlp_family
  @maven_jnlp_family ||= mock_model(MavenJnlp::MavenJnlpFamily,
    :update_snapshot_jnlp_url => :jnlp_url,
    :snapshot_jnlp_url => mock_maven_jnlp_versioned_jnlp_url,
    :snapshot_version => mock_version_str
  )
end

def mock_maven_jnlp_versioned_jnlp_url
  @versioned_jnlp_url ||= mock_model(MavenJnlp::VersionedJnlpUrl,
    :version_str => mock_version_str
  )
end

def mock_maven_jnlp_versioned_jnlp
  @versioned_jnlp ||= mock_model(MavenJnlp::VersionedJnlp,
    :versioned_jnlp_url => mock_maven_jnlp_versioned_jnlp_url
  )
end

def mock_maven_jnlp_jar
  @maven_jnlp_jar ||= mock_model( MavenJnlp::Jar)
end

def mock_maven_jnlp_native_library
  @maven_jnlp_native_library ||= mock_model( MavenJnlp::Native_library)
end

def mock_maven_jnlp_icon
  @maven_jnlp_icon ||= mock_model( MavenJnlp::Icon)
end

def mock_maven_jnlp_property
  @maven_jnlp_property ||= mock_model( MavenJnlp::Property)
end

def mock_version_str
  @version_str ||= '0.1.0-20091022.190731'
end

def mock_otrunk_example_otrunk_view_entry
  @otrunk_view_entry ||= mock_model(OtrunkExample::OtrunkViewEntry,
    :classname => "OTDataDrawingToolView",
    :standard_edit_view => false,
    :standard_view => false,
    :fq_classname => "org.concord.datagraph.state.OTDataDrawingToolView",
    :edit_view => false,
    :otrunk_import => mock_otrunk_import
  )
end

def mock_otrunk_example_otrunk_import
  @otrunk_import ||= mock_model(OtrunkExample::OtrunkImport,
    :classname => "OTSystem",
    :fq_classname => "org.concord.otrunk.OTSystem"
  )
end

def mock_otrunk_example_otml_file
  @otml_file ||= mock_model(OtrunkExample::OtmlFile,
    :content => nil,
    :path => "/Users/stephen/dev/test/rites/public/otrunk-examples/BasicExamples/basic_drawing.otml",
    :otml_category => mock_otml_category
  )
end

def mock_otrunk_example_otml_category
  @otml_category ||= mock_model(OtrunkExample::OtmlCategory,
    :name => "BasicExamples"
  )
end

