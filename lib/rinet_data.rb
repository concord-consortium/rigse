# To run the import of the RITES districts:
#
#   RAILS_ENV=production ./script/runner "(RinetData.new).run_scheduled_job"
#
# Here's an equivalent invocation in jruby:
#
#   RAILS_ENV=production jruby -J-Xmx2024m -J-server ./script/runner "RinetData.new().run_scheduled_job"
#
# If you are doing development you will want to create a dump of the state of
# your working database before any imports have been made:
#
#    rake db:dump
#
# After testing the importer you can restore the database to it's previous state
# in order to run the importer again.
#
#    rake db:load
#
# Here are the default options:
#
#   :verbose => false
#   :skip_get_csv_files => false
#   :log_level => Logger::WARN
#   :districts => @rinet_data_config[:districts]
#   :district_data_root_dir => "#{::Rails.root.to_s}/rinet_data/districts/#{@external_domain_suffix}/csv"
#
# You can customize the operation, here's an example:
#
#   If you want to:
#
#   - import data from just district "17", Lincoln
#   - skip reloading the csv files from the external SFTP server
#   - display a complete log on the console as you run the task
#   - create a log file that consists of ONLY the items recorded as :errors
#
#   RinetData.new({:districts => ["17"], :skip_get_csv_files => true, :verbose => true, :log_level => Logger::ERROR})
#
# Here is the command I use to reload the production and development databases
# (on my development setup they are the same database) to the condition just after
# initial app creation and then test the importer in JRuby with data from Cranston.
#
#   rake db:load; RAILS_ENV=production jruby -J-Xmx2024m -J-server ./script/runner \
#   'RinetData.new({:districts => ['07'], :verbose => true, :skip_get_csv_files => false}).run_scheduled_job'
#
# Note: In order to avoid issues with shell interpretation of characters in the command
# string passed to script/runner I use single-quotes around the command -- this then requires
# the use of an alternate string delimeter around: the district string: 07. I use double-quotes
# here but Ruby has additional string delimters if needed.

require 'fileutils'
require 'arrayfields'
require 'csv'

class RinetData

  class RinetDataError < ArgumentError
  end

  class RinetGetFileError < RuntimeError
  end

  class MissingDistrictFolderError < Exception
    attr_accessor :folder
    def initialize(district_folder)
      self.folder = district_folder
    end
  end



  include RinetCsvFields  # definitions for the fields we use when parsing.
  attr_reader :parsed_data
  attr_accessor :log

  @@csv_files = %w{students staff courses enrollments staff_assignments staff_sakai student_sakai}

  def initialize(options= {})
    @rinet_data_config = YAML.load_file("#{::Rails.root.to_s}/config/rinet_data.yml")[::Rails.env].symbolize_keys
    ExternalUserDomain.select_external_domain_by_server_url(@rinet_data_config[:external_domain_url])
    @external_domain_suffix = ExternalUserDomain.external_domain_suffix

    defaults = {
      :verbose => false,
      :districts => @rinet_data_config[:districts],
      :district_data_root_dir => "#{::Rails.root.to_s}/rinet_data/districts/#{@external_domain_suffix}/csv",
      :log_level => Logger::WARN,
      :drop_enrollments => false
    }

    @rinet_data_options = defaults.merge(options)
    @rinet_data_options[:log_directory] ||= @rinet_data_options[:district_data_root_dir]
    @verbose = @rinet_data_options[:verbose]
    # debugger
    @districts = @rinet_data_options[:districts]
    @district_data_root_dir = @rinet_data_options[:district_data_root_dir]
    @log_directory = @rinet_data_options[:log_directory]
    @log_path = "#{@log_directory}/import_log.txt"
    @report_path = "#{@log_directory}/report.txt"

    @errors = {:districts => {}}
    @last_log_level = nil
    @last_log_column = 0

    FileUtils.mkdir_p @log_directory
    @log = Logger.new(@log_path,'daily')
    @log.level = @rinet_data_options[:log_level]
    @report = Logger.new(@report_path,'daily')
    @report.level = Logger::INFO

    message = <<-HEREDOC

Started in: #{@district_data_root_dir} at #{Time.now}

Logging to: #{File.expand_path(@log_path)}

    HEREDOC
    log_message(message)

    clear_ar_maps
  end


  # We keep intermediate hash maps around in memory
  # for faster fetching of entities. Cleared between
  # each district.
  def clear_ar_maps
    @parsed_data = {}
    # :students => [], :staff =>[], :courses => [], :&etc. -- from CSV files
    # See rinet_csv_fields for a complete list..

    @students_active_record_map = {}
    # Example map entry:  SASID => Portal::Student

    @teachers_active_record_map = {}
    # Example map entry: CertID => Portal::Teacher

    @course_active_record_map = {}
    # Example map entry:  CourseNumber => Portal::course

    @clazz_active_record_map = {}
    # Example map entry: Portal::Clazz.id => {:teachers => [], :students => []}

    @nces_districts = {}
    @nces_schools = {}
  end


  def run_scheduled_job(opts = {})
    # disable observable behavior on useres for import task
    User.delete_observers

    start_time = Time.now
    if @rinet_data_options[:skip_get_csv_files]
      log_message "\n (skipping: get csv files, using previously downloaded data ...)\n"
    else
      log_message "\n (getting csv files ...)\n"
      get_csv_files
    end

    num_districts = num_teachers = num_students = num_courses = num_classes = 0

    @districts.each do |district|
      begin
        if @errors[:districts][district]
          log_message("\nskipping: district: #{district} due to earlier errors downloading csv data)\n", {:log_level => :error})
        else

          clear_ar_maps

          log_message "\n (parsing csv files for district #{district}...)\n"
          parse_csv_files_for_district(district)

          log_message "\n (joining data for district #{district}...)\n"
          join_data

          log_message "\n (updating models for district #{district}...)\n"
          update_models

          district_summary = <<-HEREDOC

    Import Summary for district #{district}:
      Teachers: #{@parsed_data[:staff].length}
      Students: #{@parsed_data[:students].length}
      Courses:  #{@parsed_data[:courses].length}
      Classes:  #{@parsed_data[:staff_assignments].length}

          HEREDOC
          report(district_summary)

          num_districts += 1
          num_teachers += @parsed_data[:staff].length
          num_students += @parsed_data[:students].length
          num_courses += @parsed_data[:courses].length
          num_classes += @parsed_data[:staff_assignments].length
        end
      rescue MissingDistrictFolderError => e
        log_message "Could not find district folder for district #{district} in #{e.folder}", {:log_level => 'error'}
      rescue RuntimeError => e
        log_message "Runtime exception for district #{district}", {:log_level => 'error'}
        log_message e.message, {:log_level => 'error'}
        log_message e.backtrace, {:log_level => 'debug'}
      end


    end

    end_time = Time.now
    grand_total = <<-HEREDOC

============================
Import Summary:
============================
Start Time: #{start_time.strftime("%Y-%m-%d %H:%M:%S")}
  End Time: #{end_time.strftime("%Y-%m-%d %H:%M:%S")}
   Minutes: #{((end_time - start_time)/60).to_i}

 Districts: #{num_districts}
  Teachers: #{num_teachers}
  Students: #{num_students}
   Courses: #{num_courses}
   Classes: #{num_classes}

Logged to: #{File.expand_path(@log_path)}

============================
    HEREDOC
    report(grand_total)
    verify_users
  end

  def join_data
    join_students_sakai
    join_staff_sakai
  end

  def update_models
    update_teachers
    update_students
    update_courses
    update_classes
  end

  def get_csv_files
    begin
      Net::SFTP.start(@rinet_data_config[:host], @rinet_data_config[:username] , :password => @rinet_data_config[:password]) do |sftp|
        @districts.each do |district|
          get_csv_files_for_district(district, sftp)
        end
      end
    rescue Exception => e
      log_message("get_csv_files failed: #{e.class}: #{e.message}", {:log_level => 'error'})
      raise
    end
  end

  ## sftp: a Net::SFTP::Session object
  def get_csv_files_for_district(district, sftp)
    new_date_time_key = Time.now.strftime("%Y%m%d_%H%M%S")
    local_district_path = "#{@district_data_root_dir}/#{district}/#{new_date_time_key}"
    FileUtils.mkdir_p(local_district_path)
    @@csv_files.each do |csv_file|
      # download a file or directory from the remote host
      remote_path = "#{district}/#{csv_file}.csv"
      local_path = "#{local_district_path}/#{csv_file}.csv"
      log_message("Downloading: #{remote_path} and saving to: \n  #{local_path}", {:log_level => :info})
      begin
        sftp.download!(remote_path, local_path)
      rescue RuntimeError => e
        message = "\nDownload: #{remote_path} failed: \n#{e.class}: #{e.message}\n"
        log_message(message, {:log_level => :error})
        @errors[:districts][district] = message
        # raise RinetGetFileError
      end
    end
    # debugger
    current_path = "#{@district_data_root_dir}/#{district}/current"
    FileUtils.rm_f(current_path)
    FileUtils.ln_s(local_district_path, current_path, :force => true)
  end


  def parse_csv_files_for_district(district, date_time_key='current')
    log_message "\n(parsing csv data: #{@district_data_root_dir}/#{district}/#{date_time_key})"
    parse_csv_files_in_dir("#{@district_data_root_dir}/#{district}/#{date_time_key}",@parsed_data)
  end

  def parse_csv_files_in_dir(csv_data_directory,existing_data={})
    @parsed_data = existing_data
    if File.exists?(csv_data_directory)
      count = 0
      @@csv_files.each do |csv_file|
        local_path = "#{csv_data_directory}/#{csv_file}.csv"
        log_message "\n(parsing: #{csv_data_directory}/#{csv_file}.csv)"
        key = csv_file.to_sym
        @parsed_data[key] = []
        File.open(local_path).each do |line|
          status_update(40)
          add_csv_row(key,line)
        end
      end
    else
      log_message("no data folder found: #{csv_data_directory}", {:log_level => :error})
      raise MissingDistrictFolderError.new(csv_data_directory)
    end
  end

  def add_csv_row(key,line)
    # if row.respond_to? fields
    CSV.parse(line) do |row|
      if row.class == Array
        row.fields = FIELD_DEFINITIONS[key]
        @parsed_data[key] << row
      else
        log_message("couldn't add row data for #{key}: #{line}", {:log_level => :error})
      end
    end
  end

  def join_students_sakai
    student_sakai_map = {}
    @parsed_data[:student_sakai].each do |auth_tokens|
      student_sakai_map[auth_tokens[0]] = auth_tokens[1]
    end

    new_students = @parsed_data[:students]
    @collection_length = new_students.length
    @collection_index = 0
    log_message("\n\nnprocessing: #{ @collection_length} student sakai associations: ")
    new_students.each do |student|
      log_message("#{student[:Lastname]}", {:log_level => :info, :info_in_columns => ['student-sakai associations', 6, 24]})
      found = student_sakai_map[student[:SASID]]
      if (found)
        student[:login] = found
      else
        log_message("\nstudent not found in mapping file #{student[:Firstname]} #{student[:Lastname]} (look for #{student[:SASID]}  in #{student[:District]}/current/student_sakai.csv )\n", {:log_level => :error})
      end
      @collection_index += 1
    end
  end

  def join_staff_sakai
    staff_sakai_map = {}
    @parsed_data[:staff_sakai].each do |auth_tokens|
      staff_sakai_map[auth_tokens[0]] = auth_tokens[1]
    end

    new_teachers = @parsed_data[:staff]
    @collection_length = new_teachers.length
    @collection_index = 0
    log_message("\n\nprocessing: #{ @collection_length} staff_member sakai associations: ")
    new_teachers.each do |staff_member|
      log_message("#{staff_member[:Lastname]}", {:log_level => :info, :info_in_columns => ['staff-sakai associations', 6, 24]})
      found = staff_sakai_map[staff_member[:TeacherCertNum]]
      if found
        staff_member[:login] = found
      else
        log_message("\nteacher not found in mapping file #{staff_member[:Firstname]} #{staff_member[:Lastname]} (look for #{staff_member[:TeacherCertNum]} in #{staff_member[:District]}/current/staff_sakai.csv)\n", {:log_level => :error})
      end
      @collection_index += 1
    end
  end

  def school_for(row)
    ## try to find a cached AR entity for this school:
    found_school = @nces_schools[row[:SchoolNumber]]
    return found_school unless found_school.nil?
    # pass in a row that has a :SchoolNumber
    # These are raw or processed csv rows from:
    #   students, staff, courses, enrollments, staff_assignments
    nces_school = Portal::Nces06School.find(:first, :conditions => {:SEASCH => row[:SchoolNumber]}, :select => "id, nces_district_id, NCESSCH, LEAID, SCHNO, STID, SEASCH, SCHNAM, GSLO, GSHI, PHONE, MEMBER, FTE, TOTFRL, AM, ASIAN, HISP, BLACK, WHITE, LATCOD, LONCOD, MCITY, MSTREE, MSTATE, MZIP")
    if nces_school
      # TODO, check to see if the  Portal::School.find_or_create_by_nces_school
      # method will automatically create the containing district if it
      # doesn't already exist.
      school = Portal::School.find_or_create_by_nces_school(nces_school)
      # cache the result
      @nces_schools[row[:SchoolNumber]] = school
    else
      message = <<-HEREDOC
      could not find school for: #{row[:SchoolNumber]}
      Have the NCES schools been imported? Yyou might need to run the rake tasks:
        rake portal:setup:download_nces_data
        rake portal:setup:import_nces_from_files
      HEREDOC
      log_message(message, {:log_level => :warn})
      #
      #
      # log_message("could not find school for: #{row[:SchoolNumber]} (have the NCES schools been imported?)", {:log_level => :error})
      # log_message("you might need to run the rake tasks: rake portal:setup:download_nces_data || rake portal:setup:import_nces_from_files", {:log_level => :info)
      # TODO, create one with a special name? Throw exception?
      school = nil
    end
    school
  end

  def district_for(row)
    ## try to find a cached AR entity for this district
    found_district = @nces_districts[row[:District]]
    return found_district unless found_district.nil?

    nces_district = Portal::Nces06District.find(:first, :conditions => {:STID => row[:District]});
    district = nil
    unless nces_district
      message = <<-HEREDOC
      could not find district for: #{row[:District]}
      Have the NCES schools been imported? You might need to run the rake tasks:
        rake portal:setup:download_nces_data
        rake portal:setup:import_nces_from_files
      HEREDOC
      log_message(message, {:log_level => :warn})
      # TODO, create one with a special name? Throw exception?
    else
      district = Portal::District.find_or_create_by_nces_district(nces_district)
      # cache the result:
      @nces_districts[row[:District]] = district
      log_message "(Portal::District: #{district.name})"
    end
    district
  end


  def create_or_update_user(row)
    # try to cache the data here in memory:
    unless row[:rites_user_id]
      if row[:login]
        if row[:EmailAddress] && row[:EmailAddress].length > 0
          email = row[:EmailAddress].gsub(/\s+/,"").size > 4 ? row[:EmailAddress].gsub(/\s+/,"") : nil
        end
        begin
          sakai_login = row[:login]
          rites_login = ExternalUserDomain.external_login_to_login(sakai_login)
          password = row[:Password] || row[:Birthdate]
          # crazy hack for password validation checks. (some teachers had small < 6 char passwords)
          while password.length < 6
            password = password << "x"
          end
          email = row[:email] ||
            "#{rites_login}@mailinator.com" # (temporary unique email address to pass valiadations)

          rites_user_params = {
            :login  => rites_login,
            :password => row[:Password] || row[:Birthdate],
            :password_confirmation => row[:Password] || row[:Birthdate],
            :first_name => row[:Firstname].gsub(/\s+/, ' '),
            :last_name  => row[:Lastname],
            :email => email
          }
          if User.login_exists?(rites_login)
            user = User.find_by_login(rites_login)
            user.update_attributes!(rites_user_params)
          else
            user = User.create!(rites_user_params)
          end
        rescue ExternalUserDomain::ExternalUserDomainError => e
          message = "\nCould not create user with sakai_login: #{sakai_login} because of field-validation errors:\n#{$!}"
          log_message(message, options={:log_level => :error})
          return nil
        rescue ActiveRecord::ActiveRecordError => e
          message = "\nCould not create user: #{rites_user_params[:login]} because of field-validation errors:\n#{$!}\nexternal user details: #{rites_user_params.inspect}\n"
          log_message(message, options={:log_level => :error})
          return nil
        end
        row[:rites_user_id] = user.id
        user.unsuspend! if user.state == 'suspended'
        unless user.state == 'active'
          user.register!
          user.activate!
        end
        user.roles.clear
      else
        begin
          user = nil
          message = "\n"
          beforeline = ""
          if row[:SASID]
            message << "No login found for #{row[:Firstname]} #{row[:Lastname]}, check student_sakai.csv for missing SASID: #{row[:SASID]}"
            beforeline = "\n"
          end
          if row[:TeacherCertNum]
            message << "#{beforeline}No login found for #{row[:Firstname]} #{row[:Lastname]}, check staff_sakai.csv for missing TeacherCertNum: #{row[:TeacherCertNum]}"
          end
          message << "\n"
          if message.strip.empty?
            raise(RinetData::RinetDataError, "no SASID and NO TeacherCertNum for row: #{row.join(', ')}\n")
          else
            log_message(message, {:log_level => :warn})
          end
        rescue RinetData::RinetDataError => e
          log_message("\n#{e.message}\b", {:log_level => :error})
        end
      end
    end
    user
  end

  def block_update_teachers
    @new_teachers = @existing_teachers = []
    @parsed_data[:staff].each do |row|
      if ExternalUserDomain.login_does_not_exist?(row[:login])
        @new_teachers << row
      else
        @existing_teachers << row
      end
    end

    @new_teachers = @parsed_data[:staff].select      {|row| ExternalUserDomain.login_does_not_exist?(row[:login])}
    @existing_teachers = @parsed_data[:staff].select {|row| ExternalUserDomain.login_exists?(row[:login])}

    puts "\n\nprocessing: #{new_teachers.length} teachers " if @verbose
    new_teachers.each do |teacher|
      log_message("processing teacher #{teacher[:Lastname]}", '')
      create_or_update_teacher(teacher)
    end
  end

  def update_teachers
    new_teachers = @parsed_data[:staff]
    @collection_length = new_teachers.length
    @collection_index = 0
    log_message "\n\nprocessing: #{ @collection_length} teachers:"
    new_teachers.each do |teacher|
      log_message("#{teacher[:Lastname]}", {:log_level => :info, :info_in_columns => ['teachers', 6, 24]})
      create_or_update_teacher(teacher)
      @collection_index += 1
    end
  end

  def create_or_update_teacher(row)
    # try and cache our data
    teacher = nil
    unless row[:rites_teacher_id]
      user = create_or_update_user(row)
      if user
        teacher = Portal::Teacher.find_or_create_by_user_id(user.id)
        row[:rites_user_id]=teacher.id
        # how do we find out the teacher grades?
        # teacher.grades << grade_9

        # optionally remove assignments from teacher:
        if @rinet_data_options[:drop_enrollments]
          teacher.clazzes = []
        end

        # add the teacher to the school
        school = school_for(row)
        if school
          school.add_member(teacher)
        end
        row[:rites_teacher_id] = teacher.id
        if teacher
          @teachers_active_record_map[row[:TeacherCertNum]] = teacher
        end
      end
    else
      log_message("teacher with cert: #{row[:TeacherCertNum]} previously created in this import with RITES teacher.id=#{row[:rites_teacher_id]}", {:log_level => :warn})
    end
    teacher
  end

  def update_students
    new_students = @parsed_data[:students]
    @collection_length = new_students.length
    @collection_index = 0
    log_message("\n\n(processing: #{@collection_length} students: )")
    new_students.each do |student|
      log_message("#{student[:Lastname]}", {:log_level => :info, :info_in_columns => ['students', 6, 24]})
      create_or_update_student(student)
      @collection_index += 1
    end
  end


  def create_or_update_student(row)
    student = nil
    unless row[:rites_student_id]
      user = create_or_update_user(row)
      if user
        student = user.portal_student
        unless student
          student = Portal::Student.create(:user => user)
          student.save!
          user.portal_student=student;
        end
        # optionally remove enrollments from student:
        if @rinet_data_options[:drop_enrollments]
          student.clazzes = []
        end

        # add the student to the school
        school = school_for(row)
        if school
            school.add_member(student)
        end
        row[:rites_student_id] = student.id
        # cache that results in hashtable
        @students_active_record_map[row[:SASID]] = student
      end
    else
      @log.info("student with SASID# #{row[:SASID]} already defined in this import with RITES student.id #{row[:rites_student_id]}")
    end
    row
  end


  def update_courses
    new_courses = @parsed_data[:courses]
    @collection_length = new_courses.length
    @collection_index = 0
    log_message("\n\n(processing: #{@collection_length} courses:)\n")
    new_courses.each do |course_csv_row|
      log_message("#{course_csv_row[:CourseNumber]}, #{course_csv_row[:CourseSection]}, #{course_csv_row[:Term]}, #{course_csv_row[:Title]})",
        {:log_level => :info, :info_in_columns => ['courses', 3, 40]})
      create_or_update_course(course_csv_row)
      @collection_index += 1
    end
  end


  def create_or_update_course(course_csv_row)
    # course_csv_row contains:
    #   :CourseNumber, :CourseSection, :Term, :Title, :Description, :StartDate,
    #   :EndDate, :SchoolNumber, :District, :Status, :CourseAbbreviation, :Department,
    unless course_csv_row[:rites_course]
      school = school_for(course_csv_row)
      if school
        # courses = Portal::Course.find(:all, :conditions => {:name => course_csv_row[:Title]}).detect { |course| course.school.id == school.id }
        course = Portal::Course.find_or_create_by_course_number_name_and_school_id(course_csv_row[:CourseNumber],course_csv_row[:Title], school.id)
        course_csv_row[:rites_course] = course
        # cache that results in hashtable
        cache_course_ar_map(course_csv_row[:CourseNumber],course_csv_row[:SchoolNumber],course)
      else
        log_message("no school exists when creating a course", {:log_level => :warn})
      end
    else
      log_message("course #{course_csv_row[:Title]} already defined in this import for school #{school_for(course_csv_row).name}", {:log_level => :warn})
    end
    course_csv_row
  end

  def update_classes
    # passes class member-relationship rows to create_or_update_class
    # from staff assignments:
    new_staff_assignments = @parsed_data[:staff_assignments]
    @collection_length = new_staff_assignments.length
    @collection_index = 0
    log_message("\n\n(processing: #{@collection_length} staff assignments:)\n")
    new_staff_assignments.each do |assignment|
      create_or_update_class(assignment)
      @collection_index += 1
    end

    # enroll students
    enrollments = @parsed_data[:enrollments]
    @collection_length = enrollments.length
    @collection_index = 0
    log_message("\n\n(processing: #{@collection_length} enrollments:)\n")
    enrollments.each do |enrollment|
      create_or_update_class(enrollment)
      @collection_index += 1
    end
  end

  def check_start_date(start_date)
    # example start date: 2008-08-15
    # alternate examples from RINET CSV data: 9/1/2009
    begin
      start_date = Date.parse(start_date)
    rescue ArgumentError, TypeError
      log_message("bad start date for class: '#{start_date}'", {:log_level => :error})
      nil
    end
  end

  def create_or_update_class(member_relation_row)
    # use course hashmap to find our course
    # debugger
    portal_course = cache_course_ar_map(member_relation_row[:CourseNumber],member_relation_row[:SchoolNumber])
    # unless portal_course is a Portal::Course
    unless portal_course.class == Portal::Course
      log_message("course not found #{member_relation_row[:CourseNumber]} nil: #{portal_course.nil?}: #{member_relation_row.join(', ')}", {:log_level => :error})
      return
    end

    return unless check_start_date(member_relation_row[:StartDate])

    section = member_relation_row[:CourseSection]
    start_date = DateTime.parse(member_relation_row[:StartDate])
    clazz = Portal::Clazz.find_or_create_by_course_and_section_and_start_date(portal_course,section,start_date)

    if member_relation_row[:SASID] && @students_active_record_map[member_relation_row[:SASID]]
      student =  @students_active_record_map[member_relation_row[:SASID]]
      student.add_clazz(clazz)
      log_message("#{student.last_name}", {:log_level => :info, :info_in_columns => ['student-enrollments', 6, 24]})
    elsif member_relation_row[:TeacherCertNum] && @teachers_active_record_map[member_relation_row[:TeacherCertNum]]
      clazz.teacher = @teachers_active_record_map[member_relation_row[:TeacherCertNum]]
      clazz.save
      log_message("#{clazz.teacher.last_name}", {:log_level => :info, :info_in_columns => ['teacher-assigments', 6, 24]})
    else
      log_message("\nteacher or student not found: SASID: #{member_relation_row[:SASID]} cert: #{member_relation_row[:TeacherCertNum]}\n", {:log_level => :error})
    end
    member_relation_row
  end

  def log_message(message, options={})
    # optional formmating for short :log_level => :info messages
    #   print a continuing sequence of :info messages in 3 columns of 30 characters each
    #   :info_in_columns => ['teachers', 4, 30]
    #
    defaults = {:log_level => :debug, :newline => "\n", :info_in_columns => false}
    options = defaults.merge(options)
    newline = options[:newline]
    column_format = options[:info_in_columns]
    if column_format && (options[:log_level] == :info)
      message = sprintf("%-#{column_format[2]}s", message)
      @last_log_column += 1
      if @last_log_column == 1
        index = sprintf('%6d', @collection_index)
        length = sprintf('%-6s', "#{@collection_length}:")
        line_prefix = "#{column_format[0]} #{index}/#{length}"
        message = "#{line_prefix}  #{message}"
      end
      @last_log_column %= column_format[1]
      if @last_log_column == 0
        newline = "\n"
      else
        newline = ''
      end
    else
      if @last_log_column != 0
        message = "\n" + message
        @last_log_column = 0
      end
    end
    message = message + newline
    print message if @verbose
    @log.send(options[:log_level], message)
    @last_log_level = options[:log_level]
  end

  def status_update(step_size=1)
    if @verbose
      unless defined? @step_counter
        @step_counter = 0
      end
      @step_counter += 1
      if (@step_counter % step_size) == 0
        print '.' ; STDOUT.flush
      end
    end
  end

  ##
  ## Used to print out student login info
  ##
  def random_student_login(district=@districts[(rand * (@districts.length-1)).round])
    students_file_name = "#{@district_data_root_dir}/#{district}/current/students.csv"
    student_sakai_file_name = "#{@district_data_root_dir}/#{district}/current/student_sakai.csv"
    student_rows = CSV.read(students_file_name)
    login = ""
    while login == ""
      student_row = student_rows[(rand * student_rows.length-1).round]
      student_row.fields = FIELD_DEFINITIONS[:students]
      sassid = student_row[:SASID]
      password = student_row[:Birthdate]
      open(student_sakai_file_name) do |fd|
        fd.each do |line|
           if line =~ /#{student_row[:SASID]}\s*,\s*(\S+)/
             login = $1
             break
           end
        end
      end
    end
    "Login: #{ExternalUserDomain.external_login_to_login(login)}, Pass:#{password}"
  end


  ##
  ## Used to print out staff login info
  ##
  def random_staff_login(district=@districts[(rand * (@districts.length-1)).round])
    staff_file_name = "#{@district_data_root_dir}/#{district}/current/staff.csv"
    staf_rows = CSV.read(staff_file_name)
    login = nil
    while login.nil?
      staff_row = staf_rows[(rand * staf_rows.length-1).round]
      staff_row.fields = FIELD_DEFINITIONS[:staff]
      cert_no = staff_row[:TeacherCertNum]
      password = staff_row[:Password]
      login = find_staff_login(district,cert_no)
    end
    "Login: #{ExternalUserDomain.external_login_to_login(login)}, Pass:#{password}"
  end

  def find_staff_login(district,certification_number)
    staff_sakai_file_name = "#{@district_data_root_dir}/#{district}/current/staff_sakai.csv"
    open(staff_sakai_file_name) do |fd|
      fd.each do |line|
         if line =~ /#{certification_number}\s*,\s*(\S+)/
           return $1
         end
      end
    end
    nil
  end

  #
  # TODO: What? email send to log?
  #
  def report(message)
    log_message(message, {:log_level => :error})
    @report.info(message)
  end

  #
  # report the number of students successfully imported to ActiveRecord
  # for each district:
  # @rd.verify_users
  #
  # district 07: total import records: 8533, imported to AR: 5094, missing: 3439
  # district 16: total import records: 2631, imported to AR: 6, missing: 2625
  # district 17: total import records: 1740, imported to AR: 0, missing: 1740
  # district 39: total import records: 3551, imported to AR: 1, missing: 3550
  # TODO: Some report method
  def verify_users
    report "Imported ActiveRecord entities by district:"
    @districts.each do |district|
      begin
        verify_user_imported(district)
      rescue Exception => e
        log_message("missing district data for: #{district}",{:log_level => 'error'})
        log_message("#{e.message}",{:log_level => 'error'})
      end
    end
  end

  #
  # report the number of students successfully imported to ActiveRecord
  # for a given district:
  # @rd.verify_user_imported('16')
  # => district 16: total import records: 2631, imported to AR: 1706, missing: 925
  def verify_user_imported(district=@districts.first)
    ["student","staff"].each do |type|
      file_name = "#{@district_data_root_dir}/#{district}/current/#{type}_sakai.csv"
      missing = 0; found = 0; total = 0;
      open(file_name) do |fd|
        fd.each do |line|
           if line =~ /\d+\s*,\s*(\S+)/
             login = $1
             rites_login = ExternalUserDomain.external_login_to_login(login)
             if ExternalUserDomain.external_login_exists?(login)
               found += 1
             else
               missing += 1
             end
             total += 1
           end
        end
      end
      report "district: #{district}, #{type} records found in #{File.basename(file_name)}: #{total}, imported to AR: #{found}, missing: #{missing}"
    end
  end

  def cache_course_ar_map(course_number,school_id,value=nil)
    unless (course_number && school_id)
      raise RinetDataError.new("must supply a course_number and a school")
    end
    unless @course_active_record_map[course_number]
      @course_active_record_map[course_number]={}
    end
    if value
      @course_active_record_map[course_number][school_id] = value
    end
    value = @course_active_record_map[course_number][school_id]
    return value
  end
end
