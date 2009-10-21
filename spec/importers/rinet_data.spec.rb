require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

def be_more_than(expected)
  simple_matcher do |given, matcher|
    matcher.description = "more than #{expected.inspect}"
    matcher.failure_message = "expected #{given.inspect} to be more than #{expected.inspect}"
    matcher.negative_failure_message = "expected #{given.inspect} not to be more than #{expected.inspect}"
    (given.size > expected.size)
  end
end

def be_less_than(expected)
  simple_matcher do |given, matcher|
    matcher.description = "less than #{expected.inspect}"
    matcher.failure_message = "expected #{given.inspect} to be less than #{expected.inspect}"
    matcher.negative_failure_message = "expected #{given.inspect} not to be less than #{expected.inspect}"
    (given.size < expected.size)
  end
end

def have_nces_class
  simple_matcher do |given, matcher|
    matcher.description = "#{given.inspect} should be in 'real'(nces) school"
    matcher.failure_message = "expected #{given.inspect} to be in a 'real' school"
    matcher.negative_failure_message = "expected #{given.inspect} not to be in a 'real' school"
    given.clazzes.detect { |c| c.real? }
  end
end

def be_in_nces_school
  simple_matcher do |given, matcher|
    matcher.description = "#{given.inspect} should be in 'real'(nces) school"
    matcher.failure_message = "expected #{given.inspect} to be in a 'real' school"
    matcher.negative_failure_message = "expected #{given.inspect} not to be in a 'real' school"
    given.schools.detect { |s| s.real? }
  end
end

describe RinetData do
  ##
  ## Note: This is concidered bad form: ideally we should
  ## reset all our models each time we run.
  ## in this case, we initialize and SHARE STATE because this is
  ## only run ONCE! .... you have been warned.
  ###
  before(:all) do
    @initial_users = User.find(:all)
    @initial_teachers = Portal::Teacher.find(:all)
    @initial_students = Portal::Student.find(:all)
    @initial_courses = Portal::Course.find(:all)
    @rd = RinetData.new
    
    # lets create the NCES school in our test data
    @nces_school = Factory(:portal_nces06_school, {:SEASCH => '07113'})
  end

  it "should import csv files" do
    @rd.parse_csv_files_in_dir("#{RAILS_ROOT}/resources/rinet_test_data")
    @rd.join_students_sakai
    @rd.join_staff_sakai
  end
  
  it "should have parsed data" do
    @rd.parsed_data.should_not be nil
    %w{students staff courses enrollments staff_assignments staff_sakai student_sakai}.each do |data_file|
      @rd.parsed_data[data_file.to_sym].should_not be nil
    end
  end
  
  it "should create new teachers" do
    @rd.update_teachers
    Portal::Teacher.find(:all).should be_more_than @initial_teachers
  end
  
  it "should create new students" do
    @rd.update_students
    Portal::Student.find(:all).should be_more_than @initial_students
  end
  
  it "should create new users" do
    User.find(:all).should be_more_than @initial_users
  end
  
  it "new teachers should be teaching at a valid NCES school" do
    teachers = Portal::Teacher.find(:all) - @initial_teachers
    teachers.each do |teacher|
      teacher.should be_in_nces_school
    end
  end
  
  it "new students should be enrolled in valid NCES school" do
    students = Portal::Student.find(:all) - @initial_students
    students.each do |student|
      student.should be_in_nces_school
    end
  end
  
  it "should create new courses" 
  it "should create new classes" 
  
  
  it "when the import is rerun, there should be no new students"
  it "when the import is rerun, there should be no new teachers"
  it "when the import is rerun, there should be no new classes"
  it "when the imrort is rerun, there should be no new courses"
  

end
