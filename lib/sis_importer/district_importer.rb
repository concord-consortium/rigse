module SisImporter
  class DistrictImporter
    include SisCsvFields  # definitions for the fields we use when parsing.

    attr_accessor :log
    attr_accessor :reporter
    attr_accessor :district_data_root_dir
    attr_accessor :district
    attr_accessor :parsed_data
    @@csv_files = %w{students staff courses enrollments staff_assignments }

    def initialize(opts)
      @sis_import_data_options = opts

      self.district               = opts[:district]
      self.log                    = opts[:log]
      self.reporter               = opts[:report]
      self.district_data_root_dir = opts[:district_data_root_dir]
      
      @start_time                 = Time.now
      @parsed_data            = {}
      # :students => [], :staff =>[], :courses => [], :&etc. -- from CSV files
      # See sis_csv_fields for a complete list..

      @students_active_record_map = {}
      # Example map entry:  SASID => Portal::Student

      @teachers_active_record_map = {}
      # Example map entry: CertID => Portal::Teacher

      @course_active_record_map = {}
      # Example map entry:  CourseNumber => Portal::course

      @clazz_active_record_map = {}
      # Example map entry: Portal::Clazz.id => {:teachers => [], :students => []}

      @nces_districts = {}
      @nces_schools   = {}  
      @error_users    = []
      @created_users  = []
      @updated_users  = []
    end

    def directory(timestamp="current")
      return File.join(@district_data_root_dir,self.district,timestamp)
    end

    def import
      if @log.errors[:districts][district]
        @log.error("\nskipping: district: #{district} due to earlier errors downloading csv data)\n")
      else

        @log.info "\n (parsing csv files for district #{district}...)\n"
        parse_csv_files_for_district
        @log.info "\n (joining data for district #{district}...)\n"

        @log.info "\n (updating models for district #{district}...)\n"
        update_models
        import_report(district)

        district_summary = <<-HEREDOC
          Import Summary for district #{district}:
          Teachers: #{@parsed_data[:staff].length}
          Students: #{@parsed_data[:students].length}
          Courses:  #{@parsed_data[:courses].length}
          Classes:  #{@parsed_data[:staff_assignments].length}
        HEREDOC

        @log.report(district_summary)
      end
    end

    def update_models
      update_teachers
      update_students
      update_courses
      update_classes
    end

    # TODO: Make Path helpers
    def path_for_csv(file)
      File.join(self.directory,"#{file}.csv")
    end

    def parse_csv_files_for_district
      csv_data_directory = self.directory
      @log.info "\n(parsing csv data: #{self.directory}"
      if (!File.exists?(csv_data_directory))
        @log.error("no data folder found: #{csv_data_directory}")
        raise MissingDistrictFolderError.new(csv_data_directory)
      end
      count = 0
      @@csv_files.each do |csv_file|
        local_path = path_for_csv(csv_file)
        @log.info "\n(parsing: #{local_path}"
        key = csv_file.to_sym
        @parsed_data[key] = []
        File.open(local_path).each do |line|
          # ignore comments(!)
          # comments are not valid in CSV but helps in testing
          next if line =~/^#/
          # ignore blank lines
          next if line =~/^\s+$/
          @log.status_update(40)
          add_csv_row(key,line)
        end
      end
    end

    def add_csv_row(key,line)
      # if row.respond_to? fields
      FasterCSV.parse(line) do |row|
        if row.class == Array
          row.fields = csv_field_columns[key]
          @parsed_data[key] << row
        else
          @log.error("couldn't add row data for #{key}: #{line}")
        end
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

      # initialize SisImporter with :default_school => "My School Name" 
      # to force non-matched schools into a default school.
      elsif @sis_import_data_options[:default_school]
        name = @sis_import_data_options[:default_school]
        @log.warn("using #{name} for: #{row[:SchoolNumber]} as specified in options.")
        school = Portal::School.find_by_name(name)
        if (school.nil?)
          @log.warn("Creating school #{name}.")
          school = Portal::School.create(:name => name)
        end
        if (school.district.nil?)
          @log.info("Creating district #{name}.",{:log_level => :warn})
          school.district = Portal::District.create(:name => name)
          school.save!
          school.reload
          if (school.district.nil?)
            throw "couldn't create district #{name} for school #{name}!"
          end
        end
      else
        message = <<-HEREDOC
        could not find school for: #{row[:SchoolNumber]}
        Have the NCES schools been imported? Yyou might need to run the rake tasks:
          rake portal:setup:download_nces_data
          rake portal:setup:import_nces_from_files
        HEREDOC
        @log.warn(message)
        #
        #
        # @log.info("could not find school for: #{row[:SchoolNumber]} (have the NCES schools been imported?)", {:log_level => :error})
        # @log.info("you might need to run the rake tasks: rake portal:setup:download_nces_data || rake portal:setup:import_nces_from_files", {:log_level => :info)
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
        @log.warn(message)
        # TODO, create one with a special name? Throw exception?
      else
        district = Portal::District.find_or_create_by_nces_district(nces_district)
        # cache the result:
        @nces_districts[row[:District]] = district
        @log.info "(Portal::District: #{district.name})"
      end
      district
    end


    def firstname(row)
      unless row[:firstname]
        row[:firstname] = row[:Firstname] = row[:Firstname].strip.gsub(/\222/,"'") # apostrophy in some weird encoding.
        if (row[:firstname].empty?)
          row[:firstname] = 'firstname'
        end
      end
      return row[:firstname]
    end

    def lastname(row)
      unless row[:lastname]
        row[:lastname] = row[:Lastname] = row[:Lastname].strip.gsub(/\222/,"'") # apostrophy in some weird encoding.
        if (row[:lastname].empty?)
          row[:lastname] = 'lastname'
        end
      end
      return row[:lastname]
    end
    
    def email(row)
      if row[:email]
        return row[:email]
      end
      if row[:EmailAddress] && ( row[:EmailAddress].gsub(/\s+/,"").size > 4 )
        row[:email] = email = row[:EmailAddress].gsub(/\s+/,"")
      else
        login = User.suggest_login(firstname(row),lastname(row))
        row[:email] = "#{login}@mailinator.com" 
        # (temporary unique email address to pass valiadations)
      end
      return row[:email]
    end

    def external_id(row)
      unless row[:external_id]
        row[:external_id] = row[:SASID] || row[:TeacherCertNum]
      end
      return row[:external_id]
    end

    def find_user(row)
      # first check by primary external id, then email address
      user = User.find_by_external_id(external_id(row)) || User.find_by_email(email(row))
      return user
    end

    def user_params_from_row(row)
      rites_user_params = {
        :first_name => firstname(row),
        :last_name  => lastname(row),
        :email => email(row),
        :external_id => external_id(row)
      }
    end


    def create_user(row)
      password = row[:Password] || row[:Birthdate] || ""
      login = User.suggest_login(row[:Firstname],row[:Lastname])
      # Some teachers had small < 6 char passwords, which will fail validation
      while password.length < 6
        password = password << "x"
      end
      create_params = {
        :login    => login,
        :password => password,
        :password_confirmation => password
      }
      params = user_params_from_row(row).merge(create_params)
      User.create(params)
    end

    def create_or_update_user(row)
      # try to cache the data here in memory:
      unless row[:rites_user_id]
        begin
          user = find_user(row) || create_user(row)
          if user
            user.update_attributes!(user_params_from_row(row))
          end
          push_user_change(user,row)
        rescue ExternalUserDomain::ExternalUserDomainError => e
          message = "\nCould not create user with sakai_login: #{sakai_login} because of field-validation errors:\n#{$!}"
          @log.error(message)
          push_error_row(row)
          return nil
        rescue ActiveRecord::ActiveRecordError => e
          message = "\nCould not create user: #{row.inspect} because of field-validation errors:\n#{$!}\n"
          @log.error(message)
          push_error_row(row)
          return nil
        end
        row[:rites_user_id] = user.id
        # user.unsuspend! if user.state == 'suspended'
        # if user.state == 'pending'
        #   user.activate!
        # elsif user.state != 'active'
        #   user.register!
        #   user.activate!
        # end
        if user.state != 'active'
          user.state = 'active'
          user.save
        end
        # TODO: Check this NP July 2011: Not sure why we would delete roles?
        # user.roles.clear
      end
      user
    end

    def update_teachers
      new_teachers = @parsed_data[:staff]
      @collection_length = new_teachers.length
      @collection_index = 0
      @log.info "\n\nprocessing: #{ @collection_length} teachers:"
      new_teachers.each do |teacher|
        @log.log_message("#{teacher[:Lastname]}", {:log_level => :info, :info_in_columns => ['teachers', 6, 24]})
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
          if @sis_import_data_options[:drop_enrollments]
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
        @log.warn("teacher with cert: #{row[:TeacherCertNum]} previously created in this import with RITES teacher.id=#{row[:rites_teacher_id]}")
      end
      teacher
    end

    def update_students
      new_students = @parsed_data[:students]
      @collection_length = new_students.length
      @collection_index = 0
      @log.info("\n\n(processing: #{@collection_length} students: )")
      new_students.each do |student|
        @log.log_message("#{student[:Lastname]}", {:log_level => :info, :info_in_columns => ['students', 6, 24]})
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
          if @sis_import_data_options[:drop_enrollments]
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
      @log.info("\n\n(processing: #{@collection_length} courses:)\n")
      new_courses.each do |course_csv_row|
        @log.log_message("#{course_csv_row[:CourseNumber]}, #{course_csv_row[:CourseSection]}, #{course_csv_row[:Term]}, #{course_csv_row[:Title]})",
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
          @log.info("no school exists when creating a course", {:log_level => :warn})
        end
      else
        @log.info("course #{course_csv_row[:Title]} already defined in this import for school #{school_for(course_csv_row).name}", {:log_level => :warn})
      end
      course_csv_row
    end

    def update_classes
      # passes class member-relationship rows to create_or_update_class
      # from staff assignments:
      new_staff_assignments = @parsed_data[:staff_assignments]
      @collection_length = new_staff_assignments.length
      @collection_index = 0
      @log.info("\n\n(processing: #{@collection_length} staff assignments:)\n")
      new_staff_assignments.each do |assignment|
        create_or_update_class(assignment)
        @collection_index += 1
      end

      # enroll students
      enrollments = @parsed_data[:enrollments]
      @collection_length = enrollments.length
      @collection_index = 0
      @log.info("\n\n(processing: #{@collection_length} enrollments:)\n")
      enrollments.each do |enrollment|
        create_or_update_class(enrollment)
        @collection_index += 1
      end
    end

    def check_start_date(start_date)
      # example start date: 2008-08-15
      # alternate examples from sis CSV data: 9/1/2009
      begin
        start_date = Date.parse(start_date)
      rescue ArgumentError, TypeError
        @log.info("bad start date for class: '#{start_date}'", {:log_level => :error})
        nil
      end
    end

    def create_or_update_class(member_relation_row)
      # use course hashmap to find our course
      portal_course = cache_course_ar_map(member_relation_row[:CourseNumber],member_relation_row[:SchoolNumber])
      # unless portal_course is a Portal::Course
      unless portal_course.class == Portal::Course
        @log.info("course not found #{member_relation_row[:CourseNumber]} nil: #{portal_course.nil?}: #{member_relation_row.join(', ')}", {:log_level => :error})
        return
      end

      return unless check_start_date(member_relation_row[:StartDate])

      section = member_relation_row[:CourseSection]
      start_date = DateTime.parse(member_relation_row[:StartDate])
      clazz = Portal::Clazz.find_or_create_by_course_and_section_and_start_date(portal_course,section,start_date)

      if member_relation_row[:SASID] && @students_active_record_map[member_relation_row[:SASID]]
        student =  @students_active_record_map[member_relation_row[:SASID]]
        student.add_clazz(clazz)
        @log.log_message("#{student.last_name}", {:log_level => :info, :info_in_columns => ['student-enrollments', 6, 24]})
      elsif member_relation_row[:TeacherCertNum] && @teachers_active_record_map[member_relation_row[:TeacherCertNum]]
        clazz.teacher = @teachers_active_record_map[member_relation_row[:TeacherCertNum]]
        clazz.save
        @log.log_message("#{clazz.teacher.last_name}", {:log_level => :info, :info_in_columns => ['teacher-assigments', 6, 24]})
      else
        @log.log_message("\nteacher or student not found: SASID: #{member_relation_row[:SASID]} cert: #{member_relation_row[:TeacherCertNum]}\n")
      end
      member_relation_row
    end

    ##
    ## Used to print out student login info
    ##
    def random_student_login(district=@districts[(rand * (@districts.length-1)).round])
      students_file_name = "#{@district_data_root_dir}/#{district}/current/students.csv"
      student_sakai_file_name = "#{@district_data_root_dir}/#{district}/current/student_sakai.csv"
      student_rows = FasterCSV.read(students_file_name)
      login = ""
      while login == ""
        student_row = student_rows[(rand * student_rows.length-1).round]
        student_row.fields = csv_field_columns[:students]
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
      staf_rows = FasterCSV.read(staff_file_name)
      login = nil
      while login.nil?
        staff_row = staf_rows[(rand * staf_rows.length-1).round]
        staff_row.fields = csv_field_columns[:staff]
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

    def cache_course_ar_map(course_number,school_id,value=nil)
      unless (course_number && school_id)
        raise SisImporterError.new("must supply a course_number and a school")
      end
      # TODO NP: sometimes we get keys which are strings. Force them to be trimmed
      course_number.strip! if course_number.respond_to?(:strip!)
      school_id.strip! if school_id.respond_to?(:strip!)
      unless @course_active_record_map[course_number]
        @course_active_record_map[course_number]={}
      end
      if value
        @course_active_record_map[course_number][school_id] = value
      end
      value = @course_active_record_map[course_number][school_id]
      return value
    end
    
    def created_user(user)
      return user.valid? && user.created_at > @start_time
    end

    def updated_user(user)
      return user.valid? && user.updated_at > @start_time
    end

    def push_user_change(user,row)
      role = user.portal_teacher ? "teacher" : "unknown"
      role = user.portal_student ? "student" : "unknown"
      data = [
        user.last_name,
        user.first_name,
        user.email,
        role,
        user.login,
        user.external_id,
        user.created_at,
        user.updated_at,
        user.state
      ]
      if created_user(user)
        @created_users.push(data)
      elsif updated_user(user)
        @updated_users.push(data)
      end
    end

    def push_error_row(row)
      @error_users.push(row)
    end

    def user_report(user_record_array)
      return_string = ""
      user_record_array.sort{|a,b| a[0] <=> a[0]}.each do |row|
        return_string += row.join(",")
        return_string += "\n"
      end
      return return_string
    end

    def import_report(district)
      report_path = File.join(self.directory, "report")
      FileUtils.mkdir_p(report_path)
      created_path = File.join(report_path, "users_created.csv")
      updated_path = File.join(report_path, "users_updated.csv")
      errors_path   = File.join(report_path, "users_error.dump.rb")

      data = user_report(@created_users)
      File.open(created_path, 'w') {|f| f.write(data) }

      data = user_report(@updated_users)
      File.open(updated_path, 'w') {|f| f.write(data) }
      
      data = ""
      @error_users.each do |row|
        data << row.inspect
        data << "\n"
      end
      File.open(errors_path, 'w') {|f| f.write(data) }
    end

  end
end
