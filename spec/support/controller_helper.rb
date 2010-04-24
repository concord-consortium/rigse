

# In order to run the user specs the encrypted passwords
# for the 'quentin' and 'aaron' users in spec/fixtures/users.yml
# need to be created with a REST_AUTH_SITE_KEY used for testing.
#
# suppress_warnings is a Kernel extension ...
# See: config/initializers/00_core_extensions.rb
#
suppress_warnings { REST_AUTH_SITE_KEY = 'sitekeyforrunningtests' }

class ArrayOfVersionedJars < Array
  def find_all_by_os(os)
    find { |i| i.os == os } || []
  end
end

class ArrayOfVersionedJnlpUrls < Array
  def find_by_version_str(version_str)
    find { |i| i.version_str == version_str } || []
  end
end

def generate_default_project_and_jnlps_with_mocks
  project_name, project_url = Admin::Project.default_project_name_url
  server, family, version = Admin::Project.default_jnlp_info

  @mock_jar = mock_model(MavenJnlp::Jar,
    :href => 'org/telscenter/sail-otrunk/sail-otrunk.jar',
    :name => 'sail-otrunk',
    :version_str => '0.1.0-20091009.031525-1075',
    :main => false,
    :os => nil)

  @versioned_jars = ArrayOfVersionedJars.new
  @versioned_jars[0] = @mock_jar

  @mock_property = mock_model(MavenJnlp::Property,
    :name => "maven.jnlp.version",
    :value => "all-otrunk-snapshot-0.1.0-20091013.161730")

  @mock_versioned_jnlp = mock_model(MavenJnlp::VersionedJnlp,
    :codebase => "http://jnlp.concord.org/dev",
    :j2se_version => '1.5+',
    :offline_allowed => true,
    :title => 'All OTrunk snapshot',
    :max_heap_size => "128",
    :vendor => 'Concord Consortium',
    :initial_heap_size => "32",
    :jars => @versioned_jars,
    :native_libraries => @versioned_jars,
    :properties => [@mock_property])

  @mock_versioned_jnlp_url = mock_model(MavenJnlp::VersionedJnlpUrl,
    :versioned_jnlp => @mock_versioned_jnlp,
    :version_str => version,
    :url => 'http://jnlp.concord.org/dev/org/concord/maven-jnlp/all-otrunk-snapshot/all-otrunk-snapshot-0.1.0-20070420.131610.jnlp')

  @versioned_jnlp_urls = ArrayOfVersionedJnlpUrls.new
  @versioned_jnlp_urls[0] = @mock_versioned_jnlp_url

  @mock_versioned_jnlp.stub!(:versioned_jnlp_url).and_return(@mock_versioned_jnlp_url)

  @mock_maven_jnlp_family = mock_model(MavenJnlp::MavenJnlpFamily,
    :name => family,
    :snapshot_version => version,
    :url => 'http://jnlp.concord.org/dev/org/concord/maven-jnlp/all-otrunk-snapshot/',
    :update_snapshot_jnlp_url => @mock_versioned_jnlp_url,
    :snapshot_jnlp_url => @mock_versioned_jnlp_url,
    :versioned_jnlp_urls => @versioned_jnlp_urls)

  @mock_versioned_jnlp_url.stub!(:maven_jnlp_family).and_return(@mock_maven_jnlp_family)

  @mock_gui_testing_maven_jnlp_family = mock_model(MavenJnlp::MavenJnlpFamily,
    :name => 'gui-testing',
    :snapshot_version => version,
    :url => 'http://jnlp.concord.org/dev/org/concord/maven-jnlp/all-otrunk-snapshot/',
    :update_snapshot_jnlp_url => @mock_versioned_jnlp_url, 
    :snapshot_jnlp_url        => @mock_versioned_jnlp_url,
    :versioned_jnlp_urls => @versioned_jnlp_urls)

  @mock_maven_jnlp_server = mock_model( MavenJnlp::MavenJnlpServer,
    :host => server[:host],
    :path => server[:path],
    :name => server[:name],
    :maven_jnlp_family => @mock_maven_jnlp_family)
  
  @mock_maven_jnlp_family.stub!(:maven_jnlp_server).and_return(@mock_maven_jnlp_server)
  
  @mock_project = mock_model(Admin::Project,
    :name => project_name,
    :url =>  project_url,
    :jnlp_version_str =>  version, 
    :snapshot_enabled => false,
    :enable_default_users  => APP_CONFIG[:enable_default_users],
    :states_and_provinces  => APP_CONFIG[:states_and_provinces],
    :maven_jnlp_server => @mock_maven_jnlp_server,
    :maven_jnlp_family => @mock_maven_jnlp_family)

  MavenJnlp::Jar.stub!(:find_all_by_os).and_return(@versioned_jars)
  MavenJnlp::MavenJnlpFamily.stub!(:find_by_name).with("gui-testing").and_return(@mock_gui_testing_maven_jnlp_family)
  Admin::Project.stub!(:default_project).and_return(@mock_project)

def generate_otrunk_example_with_mocks
  @mock_otml_category ||= mock_model(OtrunkExample::OtmlCategory,
    :name => "BasicExamples"
  )

  @mock_otml_file ||= mock_model(OtrunkExample::OtmlFile,
    :content => nil,
    :path => "/Users/stephen/dev/test/rites/public/otrunk-examples/BasicExamples/basic_drawing.otml",
    :otml_category => @mock_otml_category
  )

  @mock_otrunk_import ||= mock_model(OtrunkExample::OtrunkImport,
    :classname => "OTSystem",
    :fq_classname => "org.concord.otrunk.OTSystem"
  )

  @mock_otrunk_view_entry ||= mock_model(OtrunkExample::OtrunkViewEntry,
    :classname => "OTDataDrawingToolView",
    :standard_edit_view => false,
    :standard_view => false,
    :fq_classname => "org.concord.datagraph.state.OTDataDrawingToolView",
    :edit_view => false,
    :otrunk_import => @mock_otrunk_import
  )
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

def will_paginate_params(opts = {})
  { :limit => opts[:limit] || 30, :offset => opts[:offset] || 0, :include=>opts[:include] || {} }
end

