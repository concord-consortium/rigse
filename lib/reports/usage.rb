class Reports::Usage < Reports::Excel

  def initialize(opts = {})
    super(opts)

    @investigations = opts[:investigations] || Investigation.published

    @column_defs = [
      Reports::ColumnDefinition.new(:title => "Student ID",   :width => 10 ),
      Reports::ColumnDefinition.new(:title => "Student Name", :width => 25 ),
      Reports::ColumnDefinition.new(:title => "Teachers",     :width => 50 )
    ]
    @inv_start_column = {}
    @investigations.each do |inv|
      @inv_start_column[inv] = @column_defs.size
      @column_defs << Reports::ColumnDefinition.new(:title => "#{inv.name} (#{inv.id})\nAssessments Completed", :width => 4, :left_border => true)
      @column_defs << Reports::ColumnDefinition.new(:title => "% Completed", :width => 4)
      @column_defs << Reports::ColumnDefinition.new(:title => "Last run",    :width => 20)
    end
  end

  def run_report
    book = Spreadsheet::Workbook.new

    sheet1 = book.create_worksheet :name => 'Usage'
    write_sheet_headers(sheet1, @column_defs)

    @report_utils = {}  # map of offerings to Report::Util objects
    students = Portal::Student.all
    iterate_with_status(students) do |student|
      next if student.user.nil?
      next if student.user.default_user
      next if student.learners.size == 0
      teachers = student.learners.collect{|l| l.offering.clazz.teacher }.flatten.compact.uniq.map{|t| t.name }.join(",")
      # teachers = student.clazzes.collect{|c| c.teachers }.flatten.compact.uniq.map{|t| t.name }.join(",")
      row = sheet1.row(sheet1.last_row_index + 1)
      actually_wrote_data = false

      student.learners.each do |l|
        next if l.offering.nil?
        inv = l.offering.runnable
        next if inv.nil?
        next unless @investigations.include?(inv)

        @report_utils[l.offering] ||= Report::Util.new(l.offering)

        total_assessments = @report_utils[l.offering].embeddables.size
        assess_completed = @report_utils[l.offering].saveables({:learner => l}).select{|s| s.answered? }.size
        assess_percent = percent(assess_completed, total_assessments)
        last_run = l.bundle_logger.bundle_contents.compact.last
        last_run = last_run.nil? ? 'never' : last_run.created_at

        row[@inv_start_column[inv], 3] = [assess_completed, assess_percent, last_run]
        actually_wrote_data = true
      end
      next unless actually_wrote_data
      row[0,3] = [student.id, student.name, teachers]
    end

    book.write '/Users/aunger/Desktop/rites-usage.xls'
  end
end
