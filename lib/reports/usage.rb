class Reports::Usage < Reports::Excel
  def initialize(opts = {})
    super(opts)

    @investigations = opts[:investigations] || Investigation.published

    #@column_defs = [
      #Reports::ColumnDefinition.new(:title => "Student ID",   :width => 10 ),
      #Reports::ColumnDefinition.new(:title => "Student Name", :width => 25 ),
      #Reports::ColumnDefinition.new(:title => "Teachers",     :width => 50 )
    #]
    # stud.id, class, school, user.id, username, student name, teachers
    @column_defs = [
      Reports::ColumnDefinition.new(:title => "Student ID",   :width => 10),
      Reports::ColumnDefinition.new(:title => "Class",        :width => 25),
      Reports::ColumnDefinition.new(:title => "School",       :width => 25),
      Reports::ColumnDefinition.new(:title => "UserID",       :width => 25),
      Reports::ColumnDefinition.new(:title => "Username",     :width => 25),
      Reports::ColumnDefinition.new(:title => "Student Name", :width => 25),
      Reports::ColumnDefinition.new(:title => "Teachers",     :width => 50),
    ]
    
    @inv_start_column = {}
    @investigations.each do |inv|
      @inv_start_column[inv] = @column_defs.size
      @column_defs << Reports::ColumnDefinition.new(:title => "#{inv.name} (#{inv.id})\nAssessments Completed", :width => 4, :left_border => true)
      @column_defs << Reports::ColumnDefinition.new(:title => "% Completed", :width => 4)
      @column_defs << Reports::ColumnDefinition.new(:title => "Last run",    :width => 20)
    end
  end

  def run_report(stream_or_path,book=Spreadsheet::Workbook.new)
    sheet = book.create_worksheet :name => 'Usage'
    write_sheet_headers(sheet, @column_defs)

    @report_utils = {}  # map of offerings to Report::Util objects
    iterate_with_status(sorted_students_for_runnables(@investigations)) do |student|
      clazz_learners = sorted_learners(student).group_by {|l| l.offering.clazz}
      clazz_learners.each_key do |clazz|
        learners = clazz_learners[clazz]
        row = sheet.row(sheet.last_row_index + 1)
        learner_info = learner_info_cells(learners.first)
        row[0, learner_info.size] =  learner_info
        @investigations.each do |inv|
          l = learners.detect {|learner| learner.offering.runnable == inv}
          if (l)
            @report_utils[l.offering] ||= Report::Util.new(l.offering)
            total_assessments = @report_utils[l.offering].embeddables.size
            assess_completed = @report_utils[l.offering].saveables({:learner => l})
            assess_completed = assess_completed.select{|s| s.answered? }.size
            assess_percent = percent(assess_completed, total_assessments)
            last_run = l.bundle_logger.bundle_contents.compact.last
            last_run = last_run.nil? ? 'never' : last_run.created_at
            row[@inv_start_column[inv], 3] = [assess_completed, assess_percent, last_run]
          else
            row[@inv_start_column[inv], 3] = ['n/a', 'n/a', 'not assigned']
          end
        end
      end
    end

    book.write stream_or_path
  end
end
