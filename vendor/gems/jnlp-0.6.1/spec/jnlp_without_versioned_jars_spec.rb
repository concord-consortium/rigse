require File.join(File.dirname(__FILE__), 'spec_helper')

describe 'Jnlp without versioned jars' do
  before(:all) do
    @first_jnlp_path = File.join(File.dirname(__FILE__), 'fixtures', 'jnlp_without_versioned_jars.jnlp')
    @gem_dir = File.expand_path(File.dirname(__FILE__))
    @first_jnlp = Jnlp::Jnlp.new(@first_jnlp_path)    
    @first_jar = @first_jnlp.jars.first
    @fest_swing_jar = @first_jnlp.jars.find { |jar| jar.name == 'fest-swing-1.2a3' }
    @last_jar = @first_jnlp.jars[-1]
  end

  it "should be named jnlp_without_versioned_jars.jnlp" do
    @first_jnlp.name.should == 'jnlp_without_versioned_jars.jnlp'
  end

  it "should have an main_class attribute with the value 'org.concord.testing.gui.TestHelper'" do
    @first_jnlp.main_class.should == 'org.concord.testing.gui.TestHelper'
  end

  it "should have 16 jars" do
    @first_jnlp.jars.length == 16
  end

  # <jar href="org/concord/testing/gui/gui-0.1.0-20091223.210034-13.jar" main="true" />
  
  it "first jar should have the correct attributes" do
    @first_jar.filename_pack.should == 'gui-0.1.0-20091223.210034-13.jar.pack'
    @first_jar.href.should == 'org/concord/testing/gui/gui-0.1.0-20091223.210034-13.jar'

    @first_jar.version.should == ''
    @first_jar.revision.should == nil
    @first_jar.certificate_version.should == ''
    @first_jar.date_str.should == ''
    
    @first_jar.href_path.should == 'org/concord/testing/gui/'
    @first_jar.url.should == 'http://jnlp.concord.org/dev/org/concord/testing/gui/gui-0.1.0-20091223.210034-13.jar'
    @first_jar.url_pack_gz.should == 'http://jnlp.concord.org/dev/org/concord/testing/gui/gui-0.1.0-20091223.210034-13.jar.pack.gz'

    @first_jar.kind.should == 'jar'

    @first_jar.name.should == 'gui-0.1.0-20091223.210034-13'
    @first_jar.os.should == nil
    @first_jar.suffix.should == '.jar'
    @first_jar.filename.should == 'gui-0.1.0-20091223.210034-13.jar'
    @first_jar.filename_pack_gz.should == 'gui-0.1.0-20091223.210034-13.jar.pack.gz'
  end


  it "fest_swing jar should have the correct version and revision attributes" do
    @fest_swing_jar.version.should == ''
    @fest_swing_jar.revision.should == nil
  end

end
