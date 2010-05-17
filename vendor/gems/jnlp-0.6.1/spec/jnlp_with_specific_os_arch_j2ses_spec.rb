require File.join(File.dirname(__FILE__), 'spec_helper')

describe 'Jnlp with specific os/arch/j2se' do
  before(:all) do
    @jnlp_with_specific_os_arch_j2ses_path = File.join(File.dirname(__FILE__), 'fixtures', 'all-otrunk-snapshot-0.1.0-20100211.193744.jnlp')
    @jnlp_with_specific_os_arch_j2ses = Jnlp::Jnlp.new(@jnlp_with_specific_os_arch_j2ses_path)
  end

  it "should be named all-otrunk-snapshot-0.1.0-20100211.193744.jnlp" do
    @jnlp_with_specific_os_arch_j2ses.name.should == 'all-otrunk-snapshot-0.1.0-20100211.193744.jnlp'
  end

  it "should have three j2ses" do
    @jnlp_with_specific_os_arch_j2ses.j2ses.length.should == 3
  end

  it "should have an j2se_version attribute with the value '1.5+'" do
    @jnlp_with_specific_os_arch_j2ses.j2se_version.should == '1.5+'
  end

  it "should have a j2se_version attribute with the value nil if the os: mac_os_x is specified and arch is not" do
    @jnlp_with_specific_os_arch_j2ses.j2se_version('mac_os_x').should == nil
  end

  it "should have a j2se_version attribute with the value '1.5' if the os: 'mac_os_x' and arch: 'x86_64' are specified" do
    @jnlp_with_specific_os_arch_j2ses.j2se_version('mac_os_x', 'x86_64').should == '1.5'
  end

  it "should have a j2se_version attribute with the value '1.5' if the os: 'mac_os_x' and arch: 'x86_64' are specified" do
    @jnlp_with_specific_os_arch_j2ses.j2se_version('mac_os_x', 'x86_64').should == '1.5'
  end

  it "should have a j2se_version attribute with the value '1.5' if the os: 'mac_os_x' and arch: 'ppc_i386' are specified" do
    @jnlp_with_specific_os_arch_j2ses.j2se_version('mac_os_x', 'ppc_i386').should == '1.5'
  end

  it "should have a java_vm_args attribute with the value '-d32' if the os: 'mac_os_x' and arch: 'x86_64' are specified" do
    @jnlp_with_specific_os_arch_j2ses.java_vm_args('mac_os_x', 'x86_64').should == '-d32'
  end

  it "should have a java_vm_args attribute with the value nil if the os: 'mac_os_x' is specified and arch is not" do
    @jnlp_with_specific_os_arch_j2ses.java_vm_args('mac_os_x').should == nil
  end

  it "should return nil in response to the java_vm_args method if the os: 'mac_os_x' and arch: 'ppc_i386' are specified" do
    @jnlp_with_specific_os_arch_j2ses.java_vm_args('mac_os_x', 'ppc_i386').should == nil
  end
end
