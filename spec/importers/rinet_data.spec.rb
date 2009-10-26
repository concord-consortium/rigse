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
    @logger = @rd.logger
    @logger.stub!(:error).and_return(:default_value)
    @rd.run_importer(district_directory)
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
    
    describe "parsing should tolerate broken input" do
      it "should tolerate csv input with blank lines" do
        @rd.add_csv_row(:students,"")
      end
      it "should tolerate csv input with blank fields" do
        data = "Garcia,Raquel, ,,,1000139715,07113,07,0,CTP,2009-09-01,0--,230664,Y,N,,10316"
        @rd.add_csv_row(:students,data)
      end
      it "should tolerate csv input with missing fields" do
        data = "Garcia,,,,1000139715,"
        @rd.add_csv_row(:students,data)
      end
    end

    describe "should log errors on missing associations in input data, yet be resilient" do
      
      it "should log an error if an enrollment is missing a valid student" do
        @logger.should_receive(:error).with(/student not found/)
        # 007 is not a real student:
        new_enrollment = "007,GYM,1,FY,07,2009-09-01,07113,0"
        @rd.add_csv_row(:enrollments,new_enrollment)
        @rd.update_models
      end
      
      it "should log an error if an enrollment is for a non existing course" do 
        @logger.should_receive(:error).with(/course not found/)
        # SPYING_101 is not a real course:
        new_enrollment = "1000139715,SPYING_101,1,FY,07,2009-09-01,07113,0"
        @rd.add_csv_row(:enrollments,new_enrollment)
        @rd.update_models
      end
      
      it "should log an error if a staff assignment is missing a teacher" do
        @logger.should_receive(:error).with(/teacher .* not found/)
        # 007 is not a real teacher:
        new_assignment = "007,GYM,1,FY,07,2009-09-01,07113"
        @rd.add_csv_row(:staff_assignments,new_assignment)
        @rd.update_models
      end
      
      it "should log an error if a staff ssignment is missing course information" do
        @logger.should_receive(:error).with(/course not found/)
        # SPYING_101 is not a real course:
        new_assignment = "48404,SPYING_101,1,FY,07,2009-09-01,07113"
        @rd.add_csv_row(:staff_assignments,new_assignment)
        @rd.update_models
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
      courses.each do |course|
        course.should be_real
      end
    end
  
    it "should create classes with students,teachers,names, and start_times" do
      current_clazzes = Portal::Clazz.find(:all)
      current_clazzes.should be_more_than @initial_clazzes
      current_clazzes = current_clazzes - @initial_clazzes
      current_clazzes.each do |clazz|
        clazz.students.should_not be_nil
        clazz.students.size.should be > 0
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
    
    it "when the same import is rerun, there should be no new users" do
      current_courses = Portal::Course.find(:all)
      run_importer # run the import again.
      Portal::Course.find(:all).should eql current_courses
    end
  end
  
  
  describe "when csv files add entities, the new added enties *ARE ADDED* to rites" do
    it "when new lines is added to the student.csv file, there be one more student in the rites site" do
      current_students = Portal::Student.find(:all)
      # import new data which adds LPaessel
      run_importer("#{RAILS_ROOT}/resources/rinet_test_data_b") 
      Portal::Student.find(:all).size.should eql current_students.size + 1
    end
    
    it "when a PHYSICS is added to courses.csv, the class and its courses be created" do
     # import new data which adds physics
      run_importer("#{RAILS_ROOT}/resources/rinet_test_data_b")
      Portal::Clazz.find_by_name('PHYSICS').should_not be_nil
      Portal::Course.find_by_name('PHYSICS').should_not be_nil
    end
  end
  
  describe "when csv files remove entities, they are *NOT REMOVED* from rites" do
    it "when a teacher is removed from the staff.csv file, the teacher should not actually be deleted from rites" do
      current_teachers = Portal::Teacher.find(:all)
      # import new data, which removes a teacher
      run_importer("#{RAILS_ROOT}/resources/rinet_test_data_b")
      Portal::Teacher.find(:all).should eql current_teachers
    end
  
    it "when a GYM is removed from courses.csv, the class and its courses should not actually be deleted" do

      # import new data which removes a GYM class
       run_importer("#{RAILS_ROOT}/resources/rinet_test_data_b")
       Portal::Clazz.find_by_name('GYM').should_not be_nil
       Portal::Course.find_by_name('GYM').should_not be_nil
    end
  end
  
  describe "when staff assignments or student enrollments change in CSV, those changes *ARE* reflected in the rites portal" do
    it "when students are added to the the art class in the CSV file, they should be added on the rites site too" do
      # import new data which adds one user to the art class
      # and one user to a new physics class
      run_importer("#{RAILS_ROOT}/resources/rinet_test_data_b")
      art_class = Portal::Clazz.find_by_name("ART");
      Portal::Clazz.find_by_name("ART").students.size.should be 2
      Portal::Clazz.find_by_name("PHYSICS").students.size.should be 1
    end  
  end
  
  
end
