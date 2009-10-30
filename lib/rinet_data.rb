require 'fileutils'
require 'arrayfields'

# use: RAILS_ENV=production ./script/runner "(RinetData.new).run_scheduled_job"
# to run the import of all the RITES districts.
class RinetData
  include RinetCsvFields  # definitions for the fields we use when parsing.
  attr_reader :parsed_data
  attr_accessor :log

  @@csv_files = %w{students staff courses enrollments staff_assignments staff_sakai student_sakai}

  @@csv_files.each do |csv_file|
    if csv_file =~/_sakai/
      ## 
      ## Create a Caching Hash Map for sakai login info
      ## for the *_sakai csv files  eg student_sakai_map staff_sakai_map
      ##
      eval <<-END_EVAL
        def #{csv_file}_map(key)
          if @#{csv_file}_map
            return @#{csv_file}_map[key]
          end
          @#{csv_file}_map = {}
          # hash_it
          @parsed_data[:#{csv_file}].each do |auth_tokens|
            @#{csv_file}_map[auth_tokens[0]] = auth_tokens[1]
          end
          return @#{csv_file}_map[key]
        end
      END_EVAL
    end
  end
  
  def initialize(options= {})
    defaults = {
      :verbose => false,
      :log_directory => nil,
    }
    @verbose = options[:verbose] || defaults[:verbose] 
    
    # we probably want to override this later
        
    @rinet_data_config = YAML.load_file("#{RAILS_ROOT}/config/rinet_data.yml")[RAILS_ENV].symbolize_keys
    @districts = @rinet_data_config[:districts]

    ExternalUserDomain.select_external_domain_by_server_url(@rinet_data_config[:external_domain_url])
    @external_domain_suffix = ExternalUserDomain.external_domain_suffix
    
    @students_hash = {}
    # SASID => Portal::Student
    
    @teachers_hash = {}
    # CertID => Portal::Teacher
    
    @course_hash = {}
    # example: CourseNumber => Portal::course
    @clazz_hash = {}
    # Portal::Clazz.id => {:teachers => [], :students => []}

    # where we startup -- changed when we set district folder
    # log files show up here.
    log_directory = defaults[:log_directory] || self.local_dir
    FileUtils.mkdir_p log_directory
    @log = Logger.new("#{log_directory}/import_log.txt",'daily')
    import_logger("Started in #{self.local_dir} at #{Time.now}")    
  end
  
  def local_dir
    "#{RAILS_ROOT}/rinet_data/districts/#{@external_domain_suffix}/csv"
  end

  def run_importer(district_directory)
    parse_csv_files_in_dir(district_directory)
    join_data
    update_models
  end
  
  def run_scheduled_job
    import_logger "\n (getting csv files ...)\n"
    get_csv_files
    import_logger "\n (parsing csv files ...)\n"
    parse_csv_files
    import_logger "\n (joining data ...)\n"
    join_data
    import_logger "\n (updating models ...)\n"
    update_models
    summary = <<HEREDOC

Import Summary:

  Teachers: #{@parsed_data[:staff].length}
  Students: #{@parsed_data[:students].length}
  Courses:  #{@parsed_data[:courses].length}
  Classes:  #{@parsed_data[:staff_assignments].length}


HEREDOC
    import_logger(summary)
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
      @log.error("get_csv_files failed: #{e.message}")
    end
  end
  
  ## sftp: a Net::SFTP::Session object
  def get_csv_files_for_district(district, sftp)
    new_date_time_key = Time.now.strftime("%Y%m%d_%H%M%S")
    local_district_path = "#{local_dir}/#{district}/#{new_date_time_key}"
    FileUtils.mkdir_p(local_district_path)
    @@csv_files.each do |csv_file|
      # download a file or directory from the remote host
      remote_path = "#{district}/#{csv_file}.csv"
      local_path = "#{local_district_path}/#{csv_file}.csv"
      @log.info "downloading: #{remote_path} and saving to: \n  #{local_path}"
      import_logger "downloading: #{remote_path} and saving to: \n  #{local_path}"
      sftp.download!(remote_path, local_path)
    end
    current_path = "#{local_dir}/#{district}/current"
    FileUtils.ln_s(local_district_path, current_path, :force => true)
  end

  def parse_csv_files
    if @parsed_data
      @parsed_data # cached data.
    else
      @parsed_data = {}
      @districts.each do |district|
        parse_csv_files_for_district(district)
      end
    end
    # Data is now available in this format
    # @data['07']['staff'][0][:EmailAddress]
    # lets add login info
    # join_students_sakai
    #  join_staff_sakai
    @parsed_data
  end

  def parse_csv_files_for_district(district, date_time_key='current')
    import_logger "(\nparsing csv data: #{local_dir}/#{district}/#{date_time_key})"
    parse_csv_files_in_dir("#{local_dir}/#{district}/#{date_time_key}",@parsed_data)
  end

  def parse_csv_files_in_dir(local_dir_path,existing_data={})
    @parsed_data = existing_data    
    if File.exists?(local_dir_path)
      count = 0
      @@csv_files.each do |csv_file|
        local_path = "#{local_dir_path}/#{csv_file}.csv"
        import_logger "(\nparsing: #{local_dir_path}/#{csv_file}.csv)"
        key = csv_file.to_sym
        @parsed_data[key] = []
        File.open(local_path).each do |line|
          status_update(40)
          add_csv_row(key,line)
        end
      end
    else
      @log.error "no data folder found: #{local_dir_path}"
    end
  end

  def add_csv_row(key,line)
    # if row.respond_to? fields
    FasterCSV.parse(line) do |row|
      if row.class == Array
        row.fields = FIELD_DEFINITIONS[key]
        @parsed_data[key] << row
      else
        @log.error("couldn't add row data for #{key}: #{line}")
      end
    end
  end

  def join_students_sakai
    @parsed_data[:students].each do |student|
      import_logger("working with student  #{student[:Lastname]}")
      found = student_sakai_map(student[:SASID])
      if (found)
        student[:login] = found
      else
        @log.error "student not found in mapping file #{student[:Firstname]} #{student[:Lastname]} (look for #{student[:SASID]}  in #{student[:District]}/current/student_sakai.csv )"
      end
    end
  end
  
  def join_staff_sakai
    @parsed_data[:staff].each do |staff_member|
      import_logger("working with staff_member  #{staff_member[:Lastname]}")
      found = staff_sakai_map(staff_member[:TeacherCertNum])
      if (found)
        staff_member[:login] = found
      else
        @log.error "teacher not found in mapping file #{staff_member[:Firstname]} #{staff_member[:Lastname]} (look for #{staff_member[:TeacherCertNum]} in #{staff_member[:District]}/current/staff_sakai.csv)"
      end
    end
  end
  
  def school_for(row)
    # pass in a row that has a :SchoolNumber
    # These are raw or processed csv rows from: 
    #   students, staff, courses, enrollments, staff_assignments
    nces_school = Portal::Nces06School.find(:first, :conditions => {:SEASCH => row[:SchoolNumber]}, :select => "id, nces_district_id, NCESSCH, SCHNAM")
    if nces_school
      # TODO, check to see if the  Portal::School.find_or_create_by_nces_school
      # method will automatically create the containing district if it
      # doesn't already exist.
      school = Portal::School.find_or_create_by_nces_school(nces_school)
    else
      @log.warn "could not find school for: #{row[:SchoolNumber]} (have the NCES schools been imported?)"
      @log.info "you might need to run the rake tasks: rake portal:setup:download_nces_data || rake portal:setup:import_nces_from_files"
      # TODO, create one with a special name? Throw exception?
      school = nil
    end
    school
  end
  
  def district_for(row)
    nces_district = Portal::Nces06District.find(:first, :conditions => {:STID => row[:District]});
    district = nil
    unless nces_district
      @log.warn "could not find distrcit for: #{row[:District]} (have the NCES schools been imported?)"
      @log.info "you might need to run the rake tasks: rake portal:setup:download_nces_data || rake portal:setup:import_nces_from_files"
      # TODO, create one with a special name? Throw exception?
    else
      district = Portal::District.find_or_create_by_nces_district(nces_district)
      import_logger "(Portal::District: #{district.name})"
    end
    district
  end
  

  def create_or_update_user(row)
    # try to cache the data here in memory:
    unless row[:rites_user_id]
      if row[:login] 
        if row[:EmailAddress]
          email = row[:EmailAddress].gsub(/\s+/,"").size > 4 ? row[:EmailAddress].gsub(/\s+/,"") : nil
        end
        params = {
          :login  => row[:login],
          :password => row[:Password] || row[:Birthdate],
          :password_confirmation => row[:Password] || row[:Birthdate],
          :first_name => row[:Firstname],
          :last_name  => row[:Lastname],
          :email => email || "#{row[:login]}#{ExternalUserDomain.external_domain_suffix}@mailinator.com" # (temporary unique email address to pass valiadations)
        }
        begin
          if ExternalUserDomain.login_exists?(row[:login])
            user = ExternalUserDomain.find_user_by_external_login(row[:login])
            params.delete(:login)
            user.update_attributes!(params)
          else
            user = ExternalUserDomain.create_user_with_external_login(params)
          end
        rescue ExternalUserDomain::ExternalUserDomainError => e
        rescue ActiveRecord::ActiveRecordError => e
          error_message = "Could not create user: #{params[:login]} because of field-validation errors:\n#{$!}\nexternal user details: #{params.inspect}"
          @log.error(error_message)
          puts error_message if @verbose
          return nil
        end
        row[:rites_user_id]=user.id
        user.unsuspend! if user.state == 'suspended'
        unless user.state == 'active'
          user.register!
          user.activate!
        end
        user.roles.clear
      else
        begin
          if(row[:SASID])
            @log.warn("No login found for #{row[:Firstname]} #{row[:Lastname]}, check student_sakai.csv for #{row[:SASID]}")
          elsif(row[:TeacherCertNum])
            @log.warn("No login found for #{row[:Firstname]} #{row[:Lastname]}, check staff_sakai.csv for #{row[:SASID]}")
          else
            throw "no SASID and NO TeacherCertNum for #{row}"
          end
        rescue
          @log.error("could not find user data in #{row}")
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
      import_logger("processing teacher #{teacher[:Lastname]}", '')
      create_or_update_teacher(teacher)
      puts if @verbose
    end  
  end
  
  def update_teachers
    new_teachers = @parsed_data[:staff]
    import_logger "\n\n(processing: #{new_teachers.length} teachers )"
    new_teachers.each do |teacher| 
      import_logger("processing teacher: #{teacher[:Lastname]}: ")
      create_or_update_teacher(teacher)
      puts if @verbose
    end  
  end
  
  def create_or_update_teacher(row)
    # try and cache our data
    teacher = nil
    unless row[:rites_teacher_id]
      user = create_or_update_user(row)
      if (user)
        status_update
        teacher = Portal::Teacher.find_or_create_by_user_id(user.id)
        status_update
        row[:rites_user_id]=teacher.id
        # how do we find out the teacher grades?
        # teacher.grades << grade_9
    
        # add the teacher to the school
        school = school_for(row)
        if school
          school.members << teacher
          school.members.uniq!
        end
        status_update
        row[:rites_teacher_id] = teacher.id
        if teacher
          @teachers_hash[row[:TeacherCertNum]] = teacher
        end
        status_update
      end
    else
      import_logger("teacher with cert: #{row[:TeacherCertNum]} previously created in this import with RITES teacher.id=#{row[:rites_teacher_id]}")
    end
    teacher
  end
  
  def update_students
    new_students = @parsed_data[:students]
    import_logger "\n\n(processing: #{new_students.length} students )"
    new_students.each do |student| 
      import_logger "(processing student: #{student[:Lastname]})"
      create_or_update_student(student)
    end
  end
  
  def create_or_update_student(row)
    student = nil
    unless row[:rites_student_id]
      user = create_or_update_user(row)
      if (user)
        student = user.portal_student
        unless student
          student = Portal::Student.create(:user => user)
          student.save!
          user.portal_student=student;
        end

        # add the student to the school
        school = school_for(row)
        if school
            school.members << student
            school.members.uniq!
        end
        row[:rites_student_id] = student.id
        # cache that results in hashtable
        @students_hash[row[:SASID]] = student
      end
    else
      @log.info("student with SASID# #{row[:SASID]} already defined in this import with RITES student.id #{row[:rites_student_id]}")
    end
    row
  end
  
  
  def update_courses
    new_courses = @parsed_data[:courses]
    import_logger "\n\n(processing: #{new_courses.length} courses:)\n"
    new_courses.each do |nc| 
      import_logger "(creating course: #{nc[:CourseNumber]}, #{nc[:CourseSection]}, #{nc[:Term]}, #{nc[:Title]})"
      create_or_update_course(course_csv_row)
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
        courses = Portal::Course.find_all_by_name_and_school_id(course_csv_row[:Title], school.id)
        if courses.empty?
          course = Portal::Course.create!( {:name => course_csv_row[:Title], :school_id => school.id })
        else
          # TODO: what if we have multiple matches?
          if courses.class == Array
            @log.warn("Course not unique! #{course_csv_row[:Title]}, #{school.id}, found #{courses.size} entries")
            @log.info("returning first found: (#{courses[0]})")
            course = courses[0]
          else
            course = courses
          end
        end
        course_csv_row[:rites_course] = course
        # cache that results in hashtable
        @course_hash[course_csv_row[:CourseNumber]] = course_csv_row[:rites_course]
      else
        Raise ArgumentError "no school exists when creating a course"
      end
    else
      import_logger("course #{course_csv_row[:Title]} already defined in this import for school #{school_for(course_csv_row).name}", :log_leve => :info)
    end
    course_csv_row
  end
  
  def update_classes
    # passes class member-relationship rows to create_or_update_class
    # from staff assignments:
    @parsed_data[:staff_assignments].each do |nc| 
      create_or_update_class(nc)
    end
    
    # clear students schedules:
    # {'some id' => arStudent}
    @students_hash.each_value do |student|
      # student.clazzes.delete_all
    end
    
    # and re-enroll
    @parsed_data[:enrollments] .each do |nc| 
      create_or_update_class(nc)
    end

  end

  def create_or_update_class(member_relation_row)
    # use course hashmap to find our course
    # course_hash example: { CourseNumber => Portal::course }
    portal_course = @course_hash[member_relation_row[:CourseNumber]]
    unless portal_course && portal_course.class == Portal::Course
      @log.error "course not found #{member_relation_row[:CourseNumber]} nil: #{portal_course.nil?}"
      return
    end
    
    unless member_relation_row[:StartDate] && member_relation_row[:StartDate] =~/\d{4}-\d{2}-\d{2}/
      @log.error "bad start time for class: '#{member_relation_row[:StartDate]}'" unless member_relation_row =~/\d{4}-\d{2}-\d{2}/
      return
    end
    
    section = member_relation_row[:CourseSection]
    start_date = DateTime.parse(member_relation_row[:StartDate]) 
    clazz = Portal::Clazz.find_or_create_by_course_and_section_and_start_date(portal_course,section,start_date)
    
    if member_relation_row[:SASID] && @students_hash[member_relation_row[:SASID]]
      student =  @students_hash[member_relation_row[:SASID]]
      student.clazzes << clazz
      student.save
    elsif member_relation_row[:TeacherCertNum] && @teachers_hash[member_relation_row[:TeacherCertNum]]
      clazz.teacher = @teachers_hash[member_relation_row[:TeacherCertNum]]
      clazz.save
    else
      @log.error("teacher or student not found: SASID: #{member_relation_row[:SASID]} cert: #{member_relation_row[:TeacherCertNum]}")
    end
    member_relation_row
  end
  
  def import_logger(message, options={})
    new_line = options[:new_line] || "\n"
    log_level = options[:log_level] || :debug
    print message+new_line if @verbose
    @log.send(:log_level, message)
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
  
end