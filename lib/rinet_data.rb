require 'fileutils'
require 'arrayfields'

class RinetData
  include RinetCsvFields  # definitions for the fields we use when parsing.
  attr_reader :parsed_data
  
  # @@districts = %w{07 16}
  @@districts = %w{07}
  @@csv_files = %w{students staff courses enrollments staff_assignments staff_sakai student_sakai}
  @@local_dir = "#{RAILS_ROOT}/rinet_data/districts/csv"

  @@csv_files.each do |csv_file|
    if csv_file =~/_sakai/
      ## 
      ## Create a Chaching Hash Mapfor sakai login info
      ## for the *_sakai csv files
      ##
      eval <<-END_EVAL
        def #{csv_file}_map
          if @#{csv_file}_map
            return @#{csv_file}_map
          end
          @#{csv_file}_map = {}
          # hash_it
          @parsed_data[:#{csv_file}].each do |auth_tokens|
            @#{csv_file}_map[auth_tokens[0]] = auth_tokens[1]
          end
          return @#{csv_file}_map
        end
      END_EVAL
    end
  end
  
  def initialize
    @rinet_data_config = YAML.load_file("#{RAILS_ROOT}/config/rinet_data.yml")[RAILS_ENV].symbolize_keys
  end
  
  def get_csv_files
    @new_date_time_key = Time.now.strftime("%Y%m%d_%H%M%S")
    Net::SFTP.start(@rinet_data_config[:host], @rinet_data_config[:username] , :password => @rinet_data_config[:password]) do |sftp|
      @@districts.each do |district|
        local_district_path = "#{@@local_dir}/#{district}/#{@new_date_time_key}"
        FileUtils.mkdir_p(local_district_path)
        @@csv_files.each do |csv_file|
          # download a file or directory from the remote host
          remote_path = "#{district}/#{csv_file}.csv"
          local_path = "#{local_district_path}/#{csv_file}.csv"
          Rails.logger.info "downloading: #{remote_path} and saving to: \n  #{local_path}"
          sftp.download!(remote_path, local_path)
        end
        current_path = "#{@@local_dir}/#{district}/current"
        FileUtils.ln_s(local_district_path, current_path, :force => true)
      end
    end
  end

  def parse_csv_files(date_time_key='current')
    if @parsed_data
      @parsed_data # cached data.
    else
      @parsed_data = {}
      @@districts.each do |district|
        parse_csv_files_in_dir("#{@@local_dir}/#{district}/#{date_time_key}",@parsed_data)
      end
    end
    # Data is now available in this format
    # @data['07']['staff'][0][:EmailAddress]
    # lets add login info
    # join_students_sakai
    #  join_staff_sakai
    @parsed_data
  end

  def parse_csv_files_in_dir(local_dir_path,existing_data={})
    @parsed_data = existing_data
    Rails.logger.info "working on #{local_dir_path}"
    if File.exists?(local_dir_path)
      
      @@csv_files.each do |csv_file|
        local_path = "#{local_dir_path}/#{csv_file}.csv"
        fields = FIELD_DEFINITIONS["#{csv_file}_fields".to_sym]
        @parsed_data[csv_file.to_sym] = []
        FasterCSV.foreach(local_path) do |row|
          row.fields = fields
          @parsed_data[csv_file.to_sym] << row
        end
      end
    else
      Rails.logger.error "no data folder found: #{local_dir_path}"
    end
  end
  
  def join_students_sakai 
    @parsed_data[:students].each do |student|
      begin
        student[:login] = student_sakai_map[student[:SASID]]
      rescue
        Rails.logger.warn "couldn't map student #{student[:Firstname]} #{student[:Lastname]} (is staff_sakai.csv missing or out of date?)"
        Rails.logger.info "ERROR WAS: #{$!}"
      end
    end
  end
  
  def join_staff_sakai
    @parsed_data[:staff].each do |staff_member|
      begin
        staff_member[:login] = staff_sakai_map[staff_member[:TeacherCertNum]]
      rescue 
        Rails.logger.warn "couldn't map staff #{staff_member[:Firstname]} #{staff_member[:Lastname]} (is staff_sakai.csv missing or out of date?)"
        Rails.logger.info "ERROR WAS: #{$!}"
      end
    end
  end
  
  def school_for(row)
    nces_school = Portal::Nces06School.find(:first, :conditions => {:SEASCH => row[:SchoolNumber]});
    school = nil
    unless nces_school
      Rails.logger.warn "could not find school for: #{row[:SchoolNumber]} (have the NCES schools been imported?)"
      Rails.logger.info "you might need to run the rake tasks: rake portal:setup:download_nces_data || rake portal:setup:import_nces_from_files"
      # TODO, create one with a special name? Throw exception?
    else
      school = Portal::School.find_or_create_by_nces_school(nces_school)
    end
    school
  end
  
  def district_for(row)
    nces_district = Portal::Nces06District.find(:first, :conditions => {:STID => row[:District]});
    district = nil
    unless nces_district
      Rails.logger.warn "could not find distrcit for: #{row[:District]} (have the NCES schools been imported?)"
      Rails.logger.info "you might need to run the rake tasks: rake portal:setup:download_nces_data || rake portal:setup:import_nces_from_files"
      # TODO, create one with a special name? Throw exception?
    else
      district = Portal::District.find_or_create_by_nces_district(nces_district)
    end
    district
  end
  

  def create_or_update_user(row)
    # try to cache the data here in memory:
    unless row[:rites_user_id]
      email = row[:EmailAddress].gsub(/\s+/,"").size > 4 ? row[:EmailAddress].gsub(/\s+/,"") : "#{User::NO_EMAIL_STRING}#{row[:login]}@fakehost.com"
      params = {
        :login  => row[:login] || 'bugusXXXXX',
        :password => row[:Password] || row[:Birthdate],
        :password_confirmation => row[:Password] || row[:Birthdate],
        :first_name => row[:Firstname],
        :last_name  => row[:Lastname],
        :email => email
      }
      user = User.find_or_create_by_login(params)
      user.save!
      row[:rites_user_id]=user.id
      user.unsuspend! if user.state == 'suspended'
      unless user.state == 'active'
        user.register!
        user.activate!
      end
      user.roles.clear
    end
    user
  end
  
  def update_teachers
    new_teachers = @parsed_data[:staff]
    new_teachers.each { |nt| create_or_update_teacher(nt) }
  end
  
  def create_or_update_teacher(row)
    # try and cache our data
    unless row[:rites_teacher_id]
      user = create_or_update_user(row)
      teacher = Portal::Teacher.find_or_create_by_user_id(user.id)
      teacher.save!
      row[:rites_user_id]=teacher.id
      # how do we find out the teacher grades?
      # teacher.grades << grade_9
    
      # add the teacher to the school
      school = school_for(row)
      if (school)
        unless school.members.detect { |member| member.login == teacher.login }
          school.members << teacher
        end
      end
      row[:rites_teacher_id] = teacher.id
    else
      Rails.logger.info("teacher already defined in rites system")
    end
  end
  
  def update_students
    new_teachers = @parsed_data[:students]
    new_teachers.each { |nt| create_or_update_student(nt) }
  end
  
  def create_or_update_student(row)
    unless row[:rites_student_id]
      user = create_or_update_user(row)
      student = user.portal_student
      unless student
        student = Portal::Student.create(:user => user)
        student.save!
        user.portal_student=student;
      end
      row[:rites_student_id] = student.id
      # how do we find out the students grade?
      # student.grade = ??
    
      # add the student to the school
      school = school_for(row)
      if (school)
        unless school.members.detect { |member| member.login == student.login }
          school.members << student
        end
      end
      row[:rites_student_id] = student.id
    else
      Rails.logger.info("student already defined in rites system")
    end
  end
  
  
  def update_courses
    new_courses = @parsed_data[:courses]
    unless defined? @course_hash
      @course_hash = {}
    end
    new_courses.each do |nc| 
      create_or_update_course(nc)
      # cache that results in fast hash
      @course_hash[nc[:CourseNumber]] = nc[:course]
    end
  end
  
  def create_or_update_course(row)
    unless row[:rites_course_id]
      school = school_for(row);
      courses = Portal::Course.find(:all, :conditions => {:name => row[:Title]}).detect { |course| course.school.id == school.id }
      unless courses
        course = Portal::Course.create!( {:name => row[:Title], :school_id => school_for(row).id })
      else
        # TODO: what if we have multiple matches?
        if courses.size > 1
          Rails.logger.error("Too many identical courses")
        end
        course = courses[0]
      end
      row[:rites_course] = course
    else
      Rails.logger.info("course already defined in rites system")
    end
  end
  
  
  def update_classes
  end
  
  def create_or_update_class(row)

  end
  
  
end