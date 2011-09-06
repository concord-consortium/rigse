require File.expand_path('../../spec_helper', __FILE__)

module RinetDataExampleHelpers

  RSpec::Matchers.define :be_more_than do |expected|
    match                          { |given| given.size > expected.size }
    failure_message_for_should     { |given| "expected #{given.size} to be more than #{expected.size}" }
    failure_message_for_should_not { |given| "expected #{given.size} not to be more than #{expected.size}" }
    description                    { "more than #{expected.size}" }
  end

  RSpec::Matchers.define :be_less_than do |expected|
    match                          { |given| given.size < expected.size }
    failure_message_for_should     { |given| "expected #{given.size} to be less than #{expected.size}" }
    failure_message_for_should_not { |given| "expected #{given.size} not to be less than #{expected.size}" }
    description                    { "less than #{expected.size}" }
  end

  RSpec::Matchers.define :have_nces_class do
    match                          { |given| given.clazzes.detect { |c| c.real? } }
    failure_message_for_should     { |given| "expected #{given.inspect} to be in a 'real' school" }
    failure_message_for_should_not { |given| "expected #{given.inspect} not to be in a 'real' school" }
    description                    { "#{given.inspect} should be in 'real'(nces) school" }
  end

  RSpec::Matchers.define :be_in_nces_school do
    match                          { |given| given.schools.detect { |s| s.real? } }
    failure_message_for_should     { |given| "expected #{given.inspect} to be in a 'real' school" }
    failure_message_for_should_not { |given| "expected #{given.inspect} not to be in a 'real' school" }
    description                    { "#{given.inspect} should be in 'real'(nces) school" }
  end

  def run_importer(opts = {})
    defaults = {
      :districts => ["01"],
      :verbose => false,
      :district_data_root_dir => "#{::Rails.root.to_s}/resources/rinet_test_data/",
      :skip_get_csv_files => true
    }
    rinet_data_options = defaults.merge(opts)
    @rinet_data_importer = RinetData.new(rinet_data_options)
    @logger = @rinet_data_importer.log
    @rinet_data_importer.run_scheduled_job
  end

end

describe RinetData do
  include RinetDataExampleHelpers

  # make test schools
  before (:all) do
    @nces_school    = Factory(:portal_nces06_school, :SEASCH => '07113')
    @nces_school_01 = Factory(:portal_nces06_school, :SEASCH => '01')
    @nces_school_02 = Factory(:portal_nces06_school, :SEASCH => '02')
    @nces_school_03 = Factory(:portal_nces06_school, :SEASCH => '03')
  end

  ## This example group assumes that Net::SFTP is used to download RINET data.
  ## The expected behaviour of the mock objects depends highly on
  ## that of Net::SFTP, so the changes to the module should be tracked
  ## over time to keep this test relevant.
  describe "Get data from rinet" do
    before(:all) do
      @failed_connection_log = /.*get_csv_files failed.*/i
      @no_file_message = /.*no such file.*/i
      @no_file_log = /.*download.*failed.*/i
      @district_data_root_dir = "#{::Rails.root.to_s}/rinet_data/test/districts/csv"
    end

    before(:each) do
      @rinet_data = RinetData.new(:district_data_root_dir => @district_data_root_dir)
    end

    it "should be resilient in the event that it can not connect to the sftp server"

    it "should report a reasonable error message in the event that it can not connect to the sftp server" do
      #pending "Broken example"
      Net::SFTP.stub(:start).and_raise(NoMethodError.new('SFTP.start failed', 'random message'))
      @rinet_data.should_receive('log_message') do |a, b|
        a.should =~ @failed_connection_log
      end
      begin
        @rinet_data.get_csv_files
      rescue
      end
    end

    it "should be resilient in the event that a local/remote directory/file does not exist" do
      #pending "Broken example"
      sftp = double('mock_sftp')
      sftp.stub(:download!).and_raise(RuntimeError.new('open the test file to download: no such file'))
      proc = lambda { @rinet_data.get_csv_files_for_district('test07', sftp) }
      proc.should_not raise_error(RuntimeError, @no_file_message)
    end

    it "should report an error in the event that a remote directory/file does not exist" do
      #pending "Broken example"
      sftp = double('mock_sftp')
      sftp.stub(:download!).and_raise(RuntimeError.new('open the test file to download: no such file'))
      @rinet_data.should_receive('log_message').at_least(:once) do |a, b |
        a.should =~ @no_file_log
      end
      @rinet_data.get_csv_files_for_district('test07', sftp)
    end
  end

  describe "exceptions that should be thrown" do
    it "should throw MissingDistrictFolderError when trying to load non-existant district data" do
      rd = RinetData.new
      lambda {rd.parse_csv_files_for_district('fake')}.should raise_error(RinetData::MissingDistrictFolderError)
    end
  end

  describe "basic csv file parsing" do
    before(:each) do
      @initial_users = User.find(:all)
      @initial_teachers = Portal::Teacher.find(:all)
      @initial_students = Portal::Student.find(:all)
      @initial_courses  = Portal::Course.find(:all)
      @initial_clazzes  = Portal::Clazz.find(:all)
      run_importer #FIXME: ExternalUserDomain::ExternalUserDomainError
    end

    #  require 'ruby-prof'
    # it "should have performanec metrics" do
    #   RubyProf.start
    #   10.times  do
    #     run_importer
    #   end
    #   result = RubyProf.stop
    #   printer = RubyProf::GraphHtmlPrinter.new(result)
    #   printer.print(File.open('/tmp/report.html','w+'))
    # end

    it "should have parsed data" do
      @rinet_data_importer.parsed_data.should_not be_nil
      %w{students staff courses enrollments staff_assignments staff_sakai student_sakai}.each do |data_file|
        @rinet_data_importer.parsed_data[data_file.to_sym].should_not be_nil
      end
    end

    describe "parsing should tolerate broken input" do
      it "should tolerate csv input with blank lines" do
        @rinet_data_importer.add_csv_row(:students,"")
      end
      it "should tolerate csv input with blank fields" do
        csv_student_with_blank_fields = "Garcia,Raquel, ,,,1000139715,07113,07,0,CTP,2009-09-01,0--,230664,Y,N,,10316"
        @rinet_data_importer.add_csv_row(:students,csv_student_with_blank_fields)
      end

      it "should tolerate csv input with missing fields" do
        csv_student_with_missing_commas = "Garcia,,,,1000139715,"
        @rinet_data_importer.add_csv_row(:students,csv_student_with_missing_commas)
      end

      # try creating a student with a bad login
      it "should not throw an error failing validations for users" do
        student_row = {
          :Firstname => "bad",
          :Lastname => "student",
          :EmailAddress => "",
          :login => "",
          :SASID => '0078',
          :SchoolNumber => '07113' # real school
        }
        @rinet_data_importer.create_or_update_student(student_row)
      end
    end

    describe "should log errors on missing associations in input data, yet be resilient" do
      before(:each) do
        @initial_users = User.find(:all)
        @initial_teachers = Portal::Teacher.find(:all)
        @initial_students = Portal::Student.find(:all)
        @initial_courses = Portal::Course.find(:all)
        @initial_clazzes = Portal::Clazz.find(:all)
        run_importer #FIXME: ExternalUserDomain::ExternalUserDomainError
      end
      it "should log an error if an enrollment is missing a valid student" do
        #pending "Broken example"
        @logger.should_receive(:error).with(/student not found/)
        # 007 is not a real student SASID
        csv_enrollment_with_bad_student_id = "007,GYM,1,FY,07,2009-09-01,01,0"
        @rinet_data_importer.add_csv_row(:enrollments,csv_enrollment_with_bad_student_id)
        @rinet_data_importer.update_models
      end

      it "should log an error if an enrollment is for a non existing course" do
        #pending "Broken example"
        @logger.should_receive(:error).with(/course not found/)
        # SPYING_101 is not a real course:
        csv_enrollment_with_bad_course_id = "1000139715,SPYING_101,1,FY,07,2009-09-01,01,0"
        @rinet_data_importer.add_csv_row(:enrollments,csv_enrollment_with_bad_course_id)
        @rinet_data_importer.update_models
      end

      it "should log an error if a staff assignment is missing a teacher" do
        #pending "Broken example"
        @logger.should_receive(:error).with(/teacher .* not found/)
        # 007 is not a real teacher:
        csv_assignment_with_bad_teacher_id = "007,GYM,1,FY,07,2009-09-01,01"
        @rinet_data_importer.add_csv_row(:staff_assignments,csv_assignment_with_bad_teacher_id)
        @rinet_data_importer.update_models
      end

      it "should log an error if a staff ssignment is missing course information" do
        #pending "Broken example"
        @logger.should_receive(:error).with(/course not found/)
        # SPYING_101 is not a real course:
        csv_assignment_with_bad_course_id = "48404,SPYING_101,1,FY,07,2009-09-01,01"
        @rinet_data_importer.add_csv_row(:staff_assignments,csv_assignment_with_bad_course_id)
        @rinet_data_importer.update_models
      end

    end

  end

  describe "verifying that the appropriate entities get created from CSV files" do
    before(:each) do
      Portal::Course.find(:all).each { |c| c.destroy() }
      @initial_users = User.find(:all)
      @initial_teachers = Portal::Teacher.find(:all)
      @initial_students = Portal::Student.find(:all)
      @initial_courses = Portal::Course.find(:all)
      @initial_clazzes = Portal::Clazz.find(:all)
      run_importer #FIXME: ExternalUserDomain::ExternalUserDomainError
    end
    it "should create new teachers" do
      #pending "Broken example"
      Portal::Teacher.find(:all).should be_more_than(@initial_teachers)
    end

    it "should create new students" do
      Portal::Student.find(:all).should be_more_than(@initial_students)
    end

    it "should create new users" do
      User.find(:all).should be_more_than(@initial_users)
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
      Portal::Course.find(:all).should be_more_than(@initial_courses)
      courses = Portal::Course.find(:all) - @initial_courses
      courses.each do |course|
        course.should be_real
      end
    end

    it "should create classes with students,teachers,names, and start_times" do
      current_clazzes = Portal::Clazz.find(:all)
      current_clazzes.should be_more_than(@initial_clazzes)
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

    it "should not create courses without clazzes" do
      courses = Portal::Course.find(:all)
      courses.each do |course|
        course.clazzes.should_not be_empty
      end
    end

    it "should not create courses without schools" do
      courses = Portal::Course.find(:all)
      courses.each do |course|
        course.school.should_not be_nil
      end
    end

  end

  describe "Import process should not produce duplicate data" do
    before(:each) do
      @initial_users = User.find(:all)
      @initial_teachers = Portal::Teacher.find(:all)
      @initial_students = Portal::Student.find(:all)
      @initial_courses = Portal::Course.find(:all)
      @initial_clazzes = Portal::Clazz.find(:all)
      run_importer #FIXME: ExternalUserDomain::ExternalUserDomainError
    end


    it "should work for classes with same course numbers in different schools" do
      run_importer(:districts => ["02"])
      # in the test import data, teacher e and teacher d both teach a course with course Number ART
      # but they teach it in different schools
      user_d = User.find(:first, :conditions => {:first_name => 'd'})
      user_e = User.find(:first, :conditions => {:first_name => 'e'})
      user_d.should_not be_nil
      user_e.should_not be_nil
      teacher_d = user_d.portal_teacher
      teacher_e = user_e.portal_teacher
      teacher_d.should_not be_nil
      teacher_e.should_not be_nil
      art_d = teacher_d.clazzes.detect { |c| c.name = "ART"}
      art_e = teacher_e.clazzes.detect { |c| c.name = "ART"}

      art_d.course.id.should_not == art_e.course.id
      art_d.course.course_number.should == art_e.course.course_number
      art_d.course.school.should_not == art_e.course.school
    end


    it "when the same import is rerun, there should be no new students" do
      #pending "Broken example"
      current_students = Portal::Student.find(:all)
      run_importer # run the import again.
      Portal::Student.find(:all).should eql(current_students)
    end

    it "when the same import is rerun, there should be no new teachers" do
      #pending "Broken example"
      current_teachers = Portal::Teacher.find(:all)
      run_importer # run the import again.
      Portal::Teacher.find(:all).should eql(current_teachers)
    end

    it "when the same import is rerun, there should be no new classes" do
      #pending "Broken example"
      current_clazzes = Portal::Clazz.find(:all)
      run_importer # run the import again.
      Portal::Clazz.find(:all).should eql(current_clazzes)
    end

    it "when the same import is rerun, there should be no new courses" do
      #pending "Broken example"
      current_courses = Portal::Course.find(:all)
      run_importer # run the import again.
      Portal::Course.find(:all).should eql(current_courses)
    end

    it "when the same import is rerun, there should be no new users" do
      #pending "Broken example"
      current_courses = Portal::Course.find(:all)
      run_importer # run the import again.
      Portal::Course.find(:all).should eql(current_courses)
    end
  end


  describe "when multiple districts are imported new added enties are added from each district" do
    before(:each) do
      @initial_users = User.find(:all)
      @initial_teachers = Portal::Teacher.find(:all)
      @initial_students = Portal::Student.find(:all)
      @initial_courses = Portal::Course.find(:all)
      @initial_clazzes = Portal::Clazz.find(:all)
      @students
    end
    describe "district 01, and 02 contain 3 and 4 students each, with one duplicate, for a total of 6 unique students" do
      it "when students are added from the first district 3 new students are created, then 3 more are created for district 02" do
        #pending "Broken example"
        run_importer(:districts => ['01'])
        Portal::Student.find(:all).size.should eql(@initial_students.size + 3)
        run_importer(:districts => ['02'])
        Portal::Student.find(:all).size.should eql(@initial_students.size + 6)
      end
      it "when students are imported from districts [02,01] in one batch, all six new students get created at once" do
        #pending "Broken example"
        run_importer(:districts => ['02','01'])
        Portal::Student.find(:all).size.should eql(@initial_students.size + 6)
      end
      it "when students are imported from districts [01,02] in one batch, all six new students get created at once" do
        #pending "Broken example"
        run_importer(:districts => ['01','02'])
        Portal::Student.find(:all).size.should eql(@initial_students.size + 6)
      end
    end

    it "GYM is imported from district 01, and PHYSICS is imported from district 02. Both should be in Active Record tables." do
      #pending "Broken example"
      run_importer(:districts => ['01','02'])
      ["GYM","PHYSICS"].each do | name |
        Portal::Clazz.count(:conditions=>{:name => name}).should be(1)
        Portal::Course.count(:conditions=>{:name => name}).should be(1)
      end
    end

    it "ART and MATH exist in both distrcits, and ART exists in 3 schools, but all are unique courses" do
      #pending "Broken example"
      run_importer(:districts => ['01','02'])
      {"ART" => 3,"MATH" => 2}.each_pair do | name, size |
        Portal::Clazz.count(:conditions=>{:name => name}).should be(size)
        Portal::Course.count(:conditions=>{:name => name}).should be(size)
      end
    end
  end

  describe "when student enrollments change in CSV, those changes *ARE* reflected in the rites portal" do
    it "when students are added to the the ART class in csv for day two of district 1, they should be added on the rites site too" do
      #pending "Broken example"
      run_importer(:districts => ['01'])
      Portal::Clazz.find_by_name("ART").students.size.should be(1)
      run_importer(:districts => ['01_day_two'])
      Portal::Clazz.find_by_name("ART").students.size.should be(2)
    end

    it "when students are removed from the MATH class in the CSV file, what should happen ??"

  end

  describe "check_start_date validation method works" do
    before(:each) do
      @rinet_data_importer = RinetData.new #FIXME: ExternalUserDomain::ExternalUserDomainError
    end
    it "should not return nil when parsing a start_date like: '2008-08-15'" do
      #pending "Broken example"
      @rinet_data_importer.check_start_date("2008-08-15").should_not be_nil
    end

    it "should not return nil when parsing a start_date like: '9/1/2009'" do
      #pending "Broken example"
      @rinet_data_importer.check_start_date("9/1/2009").should_not be_nil
    end

    it "should return nil when parsing a start_date like: 'abc'" do
      #pending "Broken example"
      @rinet_data_importer.check_start_date("abc").should be_nil
    end

    it "should return nil when parsing a start_date like: ''" do
      #pending "Broken example"
      @rinet_data_importer.check_start_date("").should be_nil
    end

    it "should return nil when parsing a start_date like: nil" do
      #pending "Broken example"
      @rinet_data_importer.check_start_date(nil).should be_nil
    end
  end


  describe "test the course_caching method called cache_course_ar_map" do
      before(:each) do
        @importer = RinetData.new #FIXME: ExternalUserDomain::ExternalUserDomainError
      end

      it "should throw an exception if nill is passed in as course number of school id" do
        lambda {@importer.cache_course_ar_map(nil,"school_id")}.should raise_error
        lambda {@importer.cache_course_ar_map("course_number",nil)}.should raise_error
      end

      it "should not throw an exception if a course number and a school_id are passed in" do
        lambda {@importer.cache_course_ar_map("course_number","school_id")}.should_not raise_error
      end

      describe "when data has not been set" do
        it "should return null when we retrieve a  that has not been set" do
          @importer.cache_course_ar_map("course_number","school_id").should be_nil
        end
        it "should let us set a value, and return that value" do
          @importer.cache_course_ar_map("course_number","school_id","new_value").should == "new_value"
        end
      end

      describe "when data has been set" do
        before(:each) do
          @importer.cache_course_ar_map("course_number","school_id","new_value")
        end

        it "should return the value that was set" do
          @importer.cache_course_ar_map("course_number","school_id").should == "new_value"
        end

        it "should let us set a new value, and return that value" do
          @importer.cache_course_ar_map("course_number","school_id","new_new_value").should == "new_new_value"
          @importer.cache_course_ar_map("course_number","school_id").should == "new_new_value"
          @importer.cache_course_ar_map("course_number","school_id","new_new_new_value").should == "new_new_new_value"
          @importer.cache_course_ar_map("course_number","school_id").should == "new_new_new_value"
        end
      end
    end
end
