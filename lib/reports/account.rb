class Reports::Account < Reports::Excel
  @@default_time = 200.years.ago

  def initialize(opts = {})
    super(opts)

    @column_defs = [
      Reports::ColumnDefinition.new(:title => "User id",      :width => 9),
      Reports::ColumnDefinition.new(:title => "External id",  :width => 9),
      Reports::ColumnDefinition.new(:title => "User name",    :width => 25),
      Reports::ColumnDefinition.new(:title => "Login",        :width =>  9),
      Reports::ColumnDefinition.new(:title => "User type",    :width =>  9),
      Reports::ColumnDefinition.new(:title => "School",       :width => 27),
      Reports::ColumnDefinition.new(:title => "Classes",      :width => 50),
      Reports::ColumnDefinition.new(:title => "Cohorts",      :width => 50),
      Reports::ColumnDefinition.new(:title => "User created", :width => 18),
      Reports::ColumnDefinition.new(:title => "User runs",    :width => 10),
      Reports::ColumnDefinition.new(:title => "Last run",     :width => 18)
    ]
  end

  def school_name(portal_user)
    portal_user.school ? (portal_user.school.name || "School: #{portal_user.school.id}") : "No School"
  end

  def class_name(clazz)
    (clazz.name && !clazz.name.empty?) ? clazz.name : "Class: #{clazz.id}"
  end
  
  def run_report(stream_or_path)
    book = Spreadsheet::Workbook.new

    sheet1 = book.create_worksheet :name => 'Accounts'

    write_sheet_headers(sheet1, @column_defs)

    active_users = User.active.sort {|a,b| a.last_name <=> b.last_name }
    active_users.reject! { |u| u.default_user }
    teachers = active_users.map {|u| u.portal_teacher }
    students = active_users.map {|u| u.portal_student }
    [teachers, students].each do |collection|
      user_type = teachers == collection ? "Teacher" : "Student"
      collection.compact!.uniq!
      iterate_with_status(collection) do |portal_user|
        user = portal_user.user
        row = sheet1.row(sheet1.last_row_index + 1)
        user_name  = "#{user.last_name}, #{user.first_name}"
        user_login = user.login

        user_school = school_name(portal_user)
        user_classes = portal_user.clazzes.compact.map{ |c| class_name(c) }.join(',')

        user_cohorts = ""
        if user_type == "Teacher"
          user_cohorts = portal_user.cohort_list.join(", ")
        else
          clazzes = portal_user.clazzes.reject { |c| c.teacher.nil? }
          user_cohorts = clazzes.compact.map{|c| c.teacher.cohort_list }.flatten.uniq.compact.join(', ')
        end

        user_created = user.created_at

        user_runs,user_last_run = run_info(user.portal_student)  # only students have learners, so use a teacher's associated student (if any)

        row.concat [user.id, user.external_id, user_name, user_login, user_type, user_school, user_classes, user_cohorts, user_created, user_runs, user_last_run]
      end
    end
    book.write stream_or_path
  end

  private

  def run_info(user)
    return [0, 'never'] unless user && user.respond_to?(:learners)
    bundle_loggers = user.learners.collect{|l| l.bundle_logger }
    user_runs = bundle_loggers.collect{|bl| bl.bundle_contents.size }.sum
    user_last_run = bundle_loggers.collect{|bl| b = bl.bundle_contents.compact.last; b ? b.created_at : @@default_time }.sort.last
    user_last_run = "never" if user_last_run == @@default_time || user_last_run.nil?
    return [user_runs, user_last_run]
  end
end
