module SisImporter
  class Reporter
    attr_accessor :csv_errors
    attr_accessor :configuration
    attr_accessor :log
    attr_accessor :start_time
    attr_accessor :end_time
    attr_accessor :transport
    def initialize(transport)
      @transport     = transport
      @log           = transport.logger
      @start_time    = Time.now
      @csv_errors    = []
      @passwords     = {}
      @errors        = {}
      @noops         = {}
      @updates       = {}
      @creates       = {}
    end

    def errors?
      return (self.errors.length + self.csv_errors.length) > 0
    end

    def errors(clazz)
      @errors[clazz]  ||= []
    end
    
    def noops(clazz)
      @noops[clazz]   ||= []
    end
    
    def updates(clazz)
      @updates[clazz] ||= []
    end
    
    def creates(clazz)
      @creates[clazz] ||= []
    end

    def << (entity)
      clazz = entity.class
      unless (entity.valid?)
        self.errors(clazz) << entity
        return
      end

      if created(entity)
        self.creates(clazz) << entity
      elsif updated(entity)
        self.updates(clazz) << entity
      else
        self.noops(clazz)   << entity
      end
    end

    def password(user,password=nil)
      @passwords[user] = password if password
      @passwords[user]
    end

    def user_report_header
        %w[role last_name first_name email login password exernal_id created_at updated_at].join(",") << "\n"
    end

    def user_report(user)
      role = user.portal_student ? "student" : "teacher"
      password = password(user) || "<obscured>"
      row = [
        role,
        user.last_name,
        user.first_name,
        user.email,
        user.login,
        password,
        user.external_id,
        user.created_at,
        user.updated_at,
        user.state
      ]
      return row.join(",") << "\n"
    end

    def import_report
      report_path   = File.join(self.transport.local_current_district_path,"reports")
      FileUtils.mkdir_p(report_path)

      created_path    = self.transport.local_current_report_file "users_created.csv"
      updated_path    = self.transport.local_current_report_file "users_updated.csv"
      errors_path     = self.transport.local_current_report_file "users_error.csv"
      csv_errors_path = self.transport.local_current_report_file "parse_error.csv"

      File.open(created_path, 'w') do |f|
        f.write(user_report_header)
        self.creates(User).each { |user| f.write(user_report user) }
      end

      File.open(updated_path, 'w') do |f|
        f.write(user_report_header)
        self.updates(User).each { |user| f.write(user_report user) }
      end

      File.open(errors_path, 'w') do |f|
        f.write(user_report_header)
        self.errors(User).each { |user| f.write(user_report user) }
      end

      File.open(csv_errors_path, 'w') do |f|
        @csv_errors.each { |row| f.write(row.split(",") << "\n") }
      end

      self.transport.send_report "users_created.csv"
      self.transport.send_report "users_updated.csv"
      self.transport.send_report "users_error.csv"
      self.transport.send_report "parse_error.csv"

    end

    def push_error_row(bad_csv_row)
      @csv_errors << bad_csv_row
    end

    def report_summary
      c_teachers = self.creates(User).select {|u| u.portal_teacher}.uniq.size
      u_teachers = self.updates(User).select {|u| u.portal_teacher}.uniq.size
      n_teachers =   self.noops(User).select {|u| u.portal_teacher}.uniq.size

      c_students = self.creates(User).select {|u| u.portal_student}.uniq.size
      u_students = self.updates(User).select {|u| u.portal_student}.uniq.size
      n_students =   self.noops(User).select {|u| u.portal_student}.uniq.size

      c_courses = self.creates(Portal::Course).uniq.size
      u_courses = self.updates(Portal::Course).uniq.size
      n_courses =   self.noops(Portal::Course).uniq.size
      
      c_clazzes = self.creates(Portal::Clazz).uniq.size
      u_clazzes = self.updates(Portal::Clazz).uniq.size
      n_clazzes =   self.noops(Portal::Clazz).uniq.size

      district_summary = <<-HEREDOC
        Report for district: #{self.transport.district}
        Teachers:
                new      : #{c_teachers}
                updated  : #{u_teachers}
                unchanged: #{n_teachers}

        Students: 
                new      : #{c_students}
                updated  : #{u_students}
                unchanged: #{n_students}

        Courses: 
                new      : #{c_courses}
                updated  : #{u_courses}
                unchanged: #{n_courses}

        Classes:
                new      : #{c_clazzes}
                updated  : #{u_clazzes}
                unchanged: #{n_clazzes}
      HEREDOC
      @log.report(district_summary)
    end

    def created(thing)
      return thing.created_at > @start_time
    end

    def updated(thing)
      return thing.updated_at > @start_time
    end


  end
end
