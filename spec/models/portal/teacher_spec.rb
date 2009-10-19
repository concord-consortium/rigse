require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Portal::Teacher do
  before (:each) do
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
    @nces_teacher.clazzes[0].real?
  end
  
  it "teachers with real clazzes shouldn't be able to change them'" do
    @nces_teacher.clazzes[0].changeable?(@nces_teacher).should_not be_true
  end
  
  it "should support virtual teachers" do
    @virtual_teacher.should_not be_nil
  end
  
  it "virtual teachers can have classes" do
    @virtual_teacher.clazzes.should_not be_nil
    @virtual_teacher.clazzes.size.should_not be 0
  end
  
  it "vritual teachers class should not be real" do 
    @virtual_teacher.clazzes[0].real?.should_not be true
    @virtual_teacher.clazzes[0].virtual?.should be true
  end
  
  it "Virtual teachers should be able to change their clazzes'" do
    @nces_teacher.clazzes[0].changeable?(@nces_teacher).should_not be_true
  end

end
