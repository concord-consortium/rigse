require File.join(File.dirname(__FILE__), 'spec_helper')

describe Jnlp do
  before(:all) do
    @jnlp_with_certficate_versions_path = File.join(File.dirname(__FILE__), 'fixtures', 'all-otrunk-snapshot-0.1.0-20090624.030355.jnlp')
    @jnlp_with_certficate_versions = Jnlp::Jnlp.new(@jnlp_with_certficate_versions_path)
    @gem_dir = File.expand_path(File.dirname(__FILE__))
    @first_jar = @jnlp_with_certficate_versions.jars.first
    @last_jar = @jnlp_with_certficate_versions.jars[-1]
    @first_nativelib = @jnlp_with_certficate_versions.nativelibs.first
    @last_nativelib = @jnlp_with_certficate_versions.nativelibs[-1]
  end

  it "should be named all-otrunk-snapshot-0.1.0-20090624.030355.jnlp" do
    @jnlp_with_certficate_versions.name.should == 'all-otrunk-snapshot-0.1.0-20090624.030355.jnlp'
  end

  it "should have an offline_allowed attribute with the value true" do
    @jnlp_with_certficate_versions.offline_allowed.should == true
  end

  it "should have a title of 'All OTrunk snapshot'" do
    @jnlp_with_certficate_versions.title.should == 'All OTrunk snapshot'
  end

  it "should have an spec attribute with the value '1.0+'" do
    @jnlp_with_certficate_versions.spec.should == '1.0+'
  end

  it "should have an argument attribute with the value 'dummy" do
    @jnlp_with_certficate_versions.argument.should == 'dummy'
  end

  it "should have an codebase attribute with the value 'http://jnlp.concord.org/dev'" do
    @jnlp_with_certficate_versions.codebase.should == 'http://jnlp.concord.org/dev'
  end

  it "should have an main_class attribute with the value 'net.sf.sail.emf.launch.EMFLauncher3'" do
    @jnlp_with_certficate_versions.main_class.should == 'net.sf.sail.emf.launch.EMFLauncher3'
  end

  it "should have an initial_heap_size attribute with the value '32m'" do
    @jnlp_with_certficate_versions.initial_heap_size.should == '32m'
  end

  it "should have an href attribute with the value 'http://jnlp.concord.org/dev/org/concord/maven-jnlp/all-otrunk-snapshot/all-otrunk-snapshot-0.1.0-20090624.030355.jnlp'" do
    @jnlp_with_certficate_versions.href.should == 'http://jnlp.concord.org/dev/org/concord/maven-jnlp/all-otrunk-snapshot/all-otrunk-snapshot-0.1.0-20090624.030355.jnlp'
  end

  it "should have a path attribute with the value #{@jnlp_with_certficate_versions_path}" do
    @jnlp_with_certficate_versions.path.should == @jnlp_with_certficate_versions_path
  end

  it "should have an max_heap_size attribute with the value '128m'" do
    @jnlp_with_certficate_versions.max_heap_size.should == '128m'
  end

  it "should have an j2se_version attribute with the value '1.5+'" do
    @jnlp_with_certficate_versions.j2se_version.should == '1.5+'
  end

  it "should have an vendor attribute with the value 'Concord Consortium'" do
    @jnlp_with_certficate_versions.vendor.should == 'Concord Consortium'
  end

  it "should have an description attribute with the value 'Preview Basic Pas'" do
    @jnlp_with_certficate_versions.description.should == 'Preview Basic Pas'
  end

  it "should have an local_jnlp_name attribute with the value 'local-all-otrunk-snapshot-0.1.0-20090624.030355.jnlp'" do
    @jnlp_with_certficate_versions.local_jnlp_name.should == 'local-all-otrunk-snapshot-0.1.0-20090624.030355.jnlp'
  end

  it "should have an local_jnlp_href attribute" do
    @jnlp_with_certficate_versions.local_jnlp_href == "#{@gem_dir}/spec/fixtures/#{@jnlp_with_certficate_versions.local_jnlp_name}"
  end

  it "should have one property with the name: 'maven.jnlp.version' and the value 'all-otrunk-snapshot-0.1.0-20090624.030355'" do
    @jnlp_with_certficate_versions.properties.length.should == 1
    @jnlp_with_certficate_versions.properties.first.name.should == 'maven.jnlp.version'
    @jnlp_with_certficate_versions.properties.first.value.should == 'all-otrunk-snapshot-0.1.0-20090624.030355'
  end

  it "should have 67 jars" do
    @jnlp_with_certficate_versions.jars.length == 67
  end

  it "should have 2 native libraries" do
    @jnlp_with_certficate_versions.nativelibs.length == 2
  end

"2009-06-24T01:10:56Z"

  # <jar href="org/telscenter/sail-otrunk/sail-otrunk.jar" version="0.1.0-20090624.011056-1033-s1"/>

  it "first jar should have the correct attributes" do
    @first_jar.filename_pack.should == 'sail-otrunk__V0.1.0-20090624.011056-1033-s1.jar.pack'
    @first_jar.href.should == 'org/telscenter/sail-otrunk/sail-otrunk.jar'

    @first_jar.version.should == '0.1.0'
    @first_jar.revision.should == 1033
    @first_jar.certificate_version.should == 's1'
    @first_jar.date_str.should == '20090624.011056'
    @first_jar.date_time.should == DateTime.parse("2009-06-24T01:10:56Z")
  
    @first_jar.href_path.should == 'org/telscenter/sail-otrunk/'
    @first_jar.url.should == 'http://jnlp.concord.org/dev/org/telscenter/sail-otrunk/sail-otrunk.jar?version-id=0.1.0-20090624.011056-1033-s1'
    @first_jar.url_pack_gz.should == 'http://jnlp.concord.org/dev/org/telscenter/sail-otrunk/sail-otrunk__V0.1.0-20090624.011056-1033-s1.jar.pack.gz'

    @first_jar.kind.should == 'jar'

    @first_jar.name.should == 'sail-otrunk'
    @first_jar.os.should == nil
    @first_jar.suffix.should == '__V0.1.0-20090624.011056-1033-s1.jar'
    @first_jar.filename.should == 'sail-otrunk__V0.1.0-20090624.011056-1033-s1.jar'
    @first_jar.filename_pack_gz.should == 'sail-otrunk__V0.1.0-20090624.011056-1033-s1.jar.pack.gz'

  end

  it "first nativelib should have the correct attributes" do
    @first_nativelib.filename_pack.should == 'rxtx-serial-linux-nar__V2.1.7-r2-s1.jar.pack'
    @first_nativelib.href.should == 'org/concord/external/rxtx/rxtx-serial/rxtx-serial-linux-nar.jar'
    @first_nativelib.version.should == '2.1.7'
    @first_nativelib.revision.should == 2
    @first_nativelib.certificate_version.should == 's1'
    @first_nativelib.date_str.should == ''
    @first_nativelib.date_time.should == nil
    @first_nativelib.href_path.should == 'org/concord/external/rxtx/rxtx-serial/'
    @first_nativelib.url.should == 'http://jnlp.concord.org/dev/org/concord/external/rxtx/rxtx-serial/rxtx-serial-linux-nar.jar?version-id=2.1.7-r2-s1'
    @first_nativelib.url_pack_gz.should == 'http://jnlp.concord.org/dev/org/concord/external/rxtx/rxtx-serial/rxtx-serial-linux-nar__V2.1.7-r2-s1.jar.pack.gz'

    @first_nativelib.kind.should == 'nativelib'

    @first_nativelib.name.should == 'rxtx-serial-linux-nar'
    @first_nativelib.os.should == 'linux'
    @first_nativelib.suffix.should == '__V2.1.7-r2-s1.jar'
    @first_nativelib.filename.should == 'rxtx-serial-linux-nar__V2.1.7-r2-s1.jar'
    @first_nativelib.filename_pack_gz.should == 'rxtx-serial-linux-nar__V2.1.7-r2-s1.jar.pack.gz'

  end
end
