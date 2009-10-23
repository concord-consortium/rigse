require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

def be_more_than(expected)
  simple_matcher do |given, matcher|
    matcher.description = "more than #{expected.size}"
    matcher.failure_message = "expected #{given.size} to be more than #{expected.size}"
    matcher.negative_failure_message = "expected #{given.size} not to be more than #{expected.size}"
    (given.size > expected.size)
  end
end

def be_less_than(expected)
  simple_matcher do |given, matcher|
    matcher.description = "less than #{expected.size}"
    matcher.failure_message = "expected #{given.size} to be less than #{expected.size}"
    matcher.negative_failure_message = "expected #{given.size} not to be less than #{expected.size}"
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
  
  def run_importer(district_directory="#{RAILS_ROOT}/resources/rinet_test_data")
    @rd = RinetData.new
    @rd.parse_csv_files_in_dir(district_directory)
    @rd.join_students_sakai
    @rd.join_staff_sakai
    @rd.update_teachers
    @rd.update_students
    @rd.update_courses
    @rd.update_classes
  end

  ##
  ## Note: This is concidered bad form: ideally we should
  ## reset all our models each time we run.
  ## in this case, we initialize and SHARE STATE because this is
  ## only run ONCE! .... you have been warned.
  ###
  before(:each) do
    @nces_school = Factory(:portal_nces06_school, {:SEASCH => '07113'})
    @initial_users = User.find(:all)
    @initial_teachers = Portal::Teacher.find(:all)
    @initial_students = Portal::Student.find(:all)
    @initial_courses = Portal::Course.find(:all)
    @initial_clazzes = Portal::Clazz.find(:all)
    run_importer
    # lets create the NCES school in our test data
  end

  describe "basic csv file parsing" do
    it "should have parsed data" do
      @rd.parsed_data.should_not be nil
      %w{students staff courses enrollments staff_assignments staff_sakai student_sakai}.each do |data_file|
        @rd.parsed_data[data_file.to_sym].should_not be nil
      end
    end
  end
  
  describe "verifying that the appropriate entities get created from CSV files" do
    it "should create new teachers" do
      Portal::Teacher.find(:all).should be_more_than @initial_teachers
    end
  
    it "should create new students" do
      Portal::Student.find(:all).should be_more_than @initial_students
    end
  
    it "should create new users" do
      User.find(:all).should be_more_than @initial_users
    end
  
    it "new teachers should be teaching at a valid NCES school" do
      teachers = Portal::Teacher.find(:all) - @initial_teachers
      teachers.each do |teacher|
        puts "\nteacher: #{teacher.login}: #{teacher.clazzes.size}"
        teacher.should be_in_nces_school
      end
    end
  
    it "new students should be enrolled in valid NCES school" do
      students = Portal::Student.find(:all) - @initial_students
      students.each do |student|
        student.should be_in_nces_school
      end
    end
  
    it "should create new courses" do
      Portal::Course.find(:all).should be_more_than @initial_courses
      courses = Portal::Course.find(:all) - @initial_courses
      puts "\nlisting courses:\n"
      courses.each do |course|
        course.should be_real
        puts "#{course.id}-- #{course.name}: #{course.description}"
      end
    end
  
    it "should create classes with students,teachers,names, and start_times" do
      current_clazzes = Portal::Clazz.find(:all)
      current_clazzes.should be_more_than @initial_clazzes
      current_clazzes = current_clazzes - @initial_clazzes
      current_clazzes.each do |clazz|
        clazz.students.should_not be_nil
        clazz.teacher.should_not be_nil
        clazz.name.should_not be_nil
        clazz.class_word.should_not be_nil
        clazz.start_time.should_not be_nil
      end
    end
  end

  describe "Looking to prevent duplicate data" do

    it "when the same import is rerun, there should be no new students" do
      current_students = Portal::Student.find(:all)
      run_importer # run the import again.
      Portal::Student.find(:all).should eql current_students
    end
  
    it "when the same import is rerun, there should be no new teachers" do
      current_teachers = Portal::Teacher.find(:all)
      run_importer # run the import again.
      Portal::Teacher.find(:all).should eql current_teachers
    end
  
    it "when the same import is rerun, there should be no new classes" do
      current_clazzes = Portal::Clazz.find(:all)
      run_importer # run the import again.
      Portal::Clazz.find(:all).should eql current_clazzes
    end
  
    it "when the same import is rerun, there should be no new courses" do
      current_courses = Portal::Course.find(:all)
      run_importer # run the import again.
      Portal::Course.find(:all).should eql current_courses
    end
  end
  
  describe "when csv files change enrollments (student -> class mapping)" do
    
  
  end
  

  
end
