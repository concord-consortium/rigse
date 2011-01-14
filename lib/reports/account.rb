class Reports::Account < Reports::Excel
  @@default_time = 200.years.ago

  def initialize(opts = {})
    super(opts)

    @column_defs = [
      Reports::ColumnDefinition.new(:title => "User name",    :width => 25),
      Reports::ColumnDefinition.new(:title => "User type",    :width =>  9),
      Reports::ColumnDefinition.new(:title => "School",       :width => 27),
      Reports::ColumnDefinition.new(:title => "Classes",      :width => 50),
      Reports::ColumnDefinition.new(:title => "User created", :width => 18),
      Reports::ColumnDefinition.new(:title => "User runs",    :width => 10),
      Reports::ColumnDefinition.new(:title => "Last run",     :width => 18)
    ]
  end

  def run_report
    book = Spreadsheet::Workbook.new

    sheet1 = book.create_worksheet :name => 'Accounts'

    write_sheet_headers(sheet1, @column_defs)

    active_users = User.active
    iterate_with_status(active_users) do |u|
      next if u.default_user
      next unless u.portal_teacher || u.portal_student
      is_teacher = !!u.portal_teacher
      row = sheet1.row(sheet1.last_row_index + 1)
      user_name = u.name
      user_type = is_teacher ? 'Teacher' : 'Student'

      portal_user = is_teacher ? u.portal_teacher : u.portal_student
      user_school = portal_user.school ? portal_user.school.name : "No School"
      user_classes = portal_user.clazzes.compact.collect{|c| c.name }.join(',')

      user_created = u.created_at

      user_runs,user_last_run = run_info(u.portal_student)  # only students have learners, so use a teacher's associated student (if any)

      row.concat [user_name, user_type, user_school, user_classes, user_created, user_runs, user_last_run]
    end

    book.write '/Users/aunger/Desktop/rites-account.xls'
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
