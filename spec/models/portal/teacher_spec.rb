require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

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
  
  it "virtial teachers should have virtual classes" do
    @virtual_teacher.clazzes[0].should be_virtual
  end
  
  it "teachers with real clazzes shouldn't be able to change them'" do
    @nces_teacher.clazzes[0].should_not be_changeable(@nces_teacher)
  end
  
  it "should support virtual teachers" do
    @virtual_teacher.should_not be_nil
  end
  
  it "virtual teachers can have classes" do
    @virtual_teacher.clazzes.should_not be_nil
    @virtual_teacher.clazzes.size.should_not be(0)
  end
  
  it "vritual teachers class should not be real" do 
    @virtual_teacher.clazzes[0].real?.should_not be_true
    @virtual_teacher.clazzes[0].virtual?.should be_true
  end
  
  it "Teachers in virtuals schools should be able to change their clazzes'" do
    @virtual_teacher.clazzes[0].should be_changeable(@virtual_teacher)
  end

end
