require File.expand_path('../../../spec_helper', __FILE__)

describe Portal::Teacher do
  before(:each) do
    @nces_teacher = Factory(:nces_portal_teacher)
    @virtual_teacher = Factory(:portal_teacher)
    @virtual_teacher.clazzes << Factory(:portal_clazz)
  end
  
  it "should support nces teachers" do
    @nces_teacher.should_not be_nil
  end
  
  it "nces teachers should have at least one class" do
    @nces_teacher.clazzes.should_not be_nil
    @nces_teacher.clazzes.size > 0
  end
  
  it "nces teachers class should be 'real'" do 
    @nces_teacher.clazzes[0].should be_real
  end
  
  it "virtual teachers should have virtual classes" do
    @virtual_teacher.clazzes[0].should be_virtual
  end
  
  # new policy: Teachers CAN change their real clazzes
  # TODO: If we want to lock classes we need to implement a different mechanism
  it "teachers with real clazzes should be able to change them" do
    @nces_teacher.clazzes[0].should be_changeable(@nces_teacher)
  end
  
  it "should support virtual teachers" do
    @virtual_teacher.should_not be_nil
  end
  
  it "virtual teachers can have classes" do
    @virtual_teacher.clazzes.should_not be_nil
    @virtual_teacher.clazzes.size.should_not be(0)
  end
  
  it "virtual teachers class should not be real" do 
    @virtual_teacher.clazzes[0].real?.should_not be_true
    @virtual_teacher.clazzes[0].virtual?.should be_true
  end
  
  it "Teachers in virtual schools should be able to change their clazzes" do
    @virtual_teacher.clazzes[0].should be_changeable(@virtual_teacher)
  end

  # Should we enforce the school requirement via a validation, or should it be done in the controller at registration? -- Cantina-CMH 6/9/10
  # it "should not allow a teacher to exist without a school" do
  #   @virtual_teacher.should be_valid
  #   @virtual_teacher.schools = []
  #   @virtual_teacher.should_not be_valid
  #   
  #   @nces_teacher.should be_valid
  #   @nces_teacher.schools = []
  #   @nces_teacher.should_not be_valid
  # end

end
