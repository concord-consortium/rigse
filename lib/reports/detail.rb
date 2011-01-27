class Reports::Detail < Reports::Excel

  def initialize(opts = {})
    super(opts)

    @investigations = opts[:investigations] || Investigation.published

    @common_columns = [
      Reports::ColumnDefinition.new(:title => "Student ID",   :width => 10),
      Reports::ColumnDefinition.new(:title => "Student Name", :width => 25),
      Reports::ColumnDefinition.new(:title => "Teachers",     :width => 50),
      Reports::ColumnDefinition.new(:title => "Assessments Completed", :width => 4, :left_border => true),
      Reports::ColumnDefinition.new(:title => "% Completed", :width => 4),
      Reports::ColumnDefinition.new(:title => "Last run",    :width => 20),
    ]
  end

  def run_report(stream_or_path)
    book = Spreadsheet::Workbook.new

    print "Prepping worksheets..." if @verbose
    @inv_sheet = {}
    @investigations.each do |inv|
      # puts "Investigation #{"%4d" % inv.id}"
      @inv_sheet[inv] = book.create_worksheet :name => inv.name
      sheet_defs = @common_columns.clone
      answer_defs = []
      inv.activities.student_only.each do |a|
        sheet_defs << Reports::ColumnDefinition.new(:title => "#{a.name}\nAssessments Completed", :width => 4, :left_border => true)
        sheet_defs << Reports::ColumnDefinition.new(:title => "% Completed", :width => 4)
        reportables = a.reportable_elements.map {|re| re[:embeddable]}
        first = true
        reportables.each do |r|
          answer_defs << Reports::ColumnDefinition.new(:title => clean_text((r.respond_to?(:prompt) ? r.prompt : r.name)), :width => 25, :left_border => first)
          first = false
        end
      end

      col_defs = sheet_defs + answer_defs
      write_sheet_headers(@inv_sheet[inv], col_defs)
    end
    puts " done." if @verbose

    @report_utils = {}  # map of offerings to Report::Util objects
    students = Portal::Student.all
    iterate_with_status(students) do |student|
      next if student.user.nil?
      next if student.user.default_user
      next if student.learners.size == 0

      student.learners.each do |l|
        next if l.offering.nil?
        inv = l.offering.runnable
        next if inv.nil?
        next unless @investigations.include?(inv)

        @report_utils[l.offering] ||= Report::Util.new(l.offering)

        teachers = l.offering.clazz.teachers.flatten.compact.uniq.map{|t| t.name }.join(",")

        total_assessments = @report_utils[l.offering].embeddables.size
        assess_completed = @report_utils[l.offering].saveables({:learner => l}).select{|s| s.answered? }.size
        assess_percent = percent(assess_completed, total_assessments)
        last_run = l.bundle_logger.bundle_contents.compact.last
        last_run = last_run.nil? ? 'never' : last_run.created_at

        sheet = @inv_sheet[inv]
        row = sheet.row(sheet.last_row_index + 1)
        row[0, 3] = [student.id, student.name, teachers, assess_completed, assess_percent, last_run]

        all_answers = []
        inv.activities.student_only.each do |a|
          reportables = a.reportable_elements.map {|re| re[:embeddable]}
          answers = reportables.map{|r| @report_utils[l.offering].saveable(l,r)}
          answered_answers = answers.select{|s| s.answered? }
          row.concat [answered_answers.size, percent(answered_answers.size, reportables.size)]
          all_answers += answers.collect{|ans| ans.answer }
        end
        row.concat all_answers
      end
    end

    book.write stream_or_path
  end
end
