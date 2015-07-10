require File.expand_path('../../../spec_helper', __FILE__)

#
#  Open question: should these spec tests be named for the models, or the join
#  table which is actually being tested?
#
describe Portal::TeacherClazz do
  describe "testing many to many mapping for teachers <=> clazzes" do
    it "teachers should be able to add clazzes" do
      teacher = Factory :portal_teacher, {:clazzes => []}
      clazz = Factory :portal_clazz
      teacher.add_clazz(clazz)
      teacher.reload
      teacher.clazzes.should include(clazz)
    end
    it "there should be no double enrollment if a teacher adds a class twice" do
      teacher = Factory :portal_teacher, {:clazzes => []}
      clazz = Factory :portal_clazz
      teacher.add_clazz(clazz)
      teacher.add_clazz(clazz)
      teacher.add_clazz(clazz)
      teacher.reload
      teacher.clazzes.should include(clazz)
      teacher.clazzes.should have(1).things
    end
    
    it "clazzes should be alble to have more than one teacher" do
      teacher = Factory :portal_teacher, {:clazzes => []}
      second_teacher = Factory :portal_teacher, {:clazzes => []}
      clazz = Factory :portal_clazz
      teacher.add_clazz(clazz)
      second_teacher.add_clazz(clazz)
      teacher.reload
      second_teacher.reload
      clazz.reload
      teacher.clazzes.should include(clazz)
      second_teacher.clazzes.should include(clazz)
      clazz.teachers.should include(teacher)
      clazz.teachers.should include(second_teacher)
    end
    
    it "clazzes which have multiple teachers are owned by both teachers" do
      teacher = Factory :portal_teacher, {:clazzes => []}
      second_teacher = Factory :portal_teacher, {:clazzes => []}
      clazz = Factory :portal_clazz
      teacher.add_clazz(clazz)
      second_teacher.add_clazz(clazz)
      teacher.reload
      second_teacher.reload
      clazz.reload
      clazz.should be_virtual
      clazz.should be_changeable(teacher.user)
      clazz.should be_changeable(second_teacher.user)
      clazz.should be_changeable(teacher)
      clazz.should be_changeable(second_teacher)
    end
    
    it "should remove this teacher from the specified class" do
      clazz = Factory :portal_clazz
      teacher = Factory :portal_teacher, {:clazzes => [clazz]}
      teacher.clazzes.should include(clazz)
      teacher.remove_clazz(clazz)
      teacher.reload
      teacher.clazzes.should_not include(clazz)
    end
  end
  
  describe "preserving leagacy one to many mapping for teachers <= clazzes" do
    it "clazz.teacher=@teacher assignment should make @teacher a teacher of clazz" do
      teacher = Factory :portal_teacher, {:clazzes => []}
      clazz = Factory :portal_clazz
      clazz.teacher = teacher
      teacher.reload
      teacher.clazzes.should include(clazz)
    end
    
    it "clazz.teacher=@teacher assignment shouldn't make a duplicate teacher entry" do
      teacher = Factory :portal_teacher, {:clazzes => []}
      clazz = Factory :portal_clazz
      clazz.teacher = teacher
      clazz.teacher = teacher
      clazz.teacher = teacher
      teacher.reload
      teacher.clazzes.should include(clazz)
      teacher.clazzes.should have(1).things
    end
    
    it "clazz.teacher reader should return the first teacher if there is one" do
      teacher = Factory :portal_teacher, {:clazzes => []}
      second_teacher = Factory :portal_teacher, {:clazzes => []}
      clazz = Factory :portal_clazz
      clazz.teacher = teacher
      clazz.teacher = second_teacher
      teacher.reload
      clazz.reload
      clazz.teacher.should == teacher
    end
    
    it "clazz.teacher should return nil if there isn't a teacher" do
      clazz = Factory :portal_clazz
      clazz.teacher.should be_nil
    end
    
  end
  
end
