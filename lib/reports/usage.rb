class Reports::Usage < Reports::Excel
  def initialize(opts = {})
    super(opts)

    @runnables =  opts[:runnables]  || Investigation.published
    @report_learners = opts[:report_learners] || report_learners_for_runnables(@runnables)
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
    
    @runnable_start_column = {}
    @runnables.each do |runnable|
      @runnable_start_column[runnable] = @column_defs.size
      @column_defs << Reports::ColumnDefinition.new(:title => "#{runnable.name} (#{runnable.id})\nAssessments Completed", :width => 4, :left_border => true)
      @column_defs << Reports::ColumnDefinition.new(:title => "% Completed", :width => 4)
      @column_defs << Reports::ColumnDefinition.new(:title => "Last run",    :width => 20)
    end
  end

  def sorted_learners()
    @report_learners.sort_by {|l| [l.school_name, l.class_name, l.student_name, l.runnable_name]}
  end

  def run_report(stream_or_path,book=Spreadsheet::Workbook.new)
    sheet = book.create_worksheet :name => 'Usage'
    write_sheet_headers(sheet, @column_defs)
    student_learners = sorted_learners.group_by {|l| l.student_id }
    student_learners.each_key do |student_id|
      learners = student_learners[student_id]
      row = sheet.row(sheet.last_row_index + 1)
      learner_info = report_learner_info_cells(learners.first)
      row[0, learner_info.size] =  learner_info
      @runnables.each do |runnable|
        l = learners.detect {|learner| learner.runnable_type == runnable.class.to_s && learner.runnable_id == runnable.id}
        if (l)
          total_assessments = l.num_answerables
          assess_completed =  l.num_answered
          assess_percent = percent(assess_completed, total_assessments)
          last_run = l.last_run || 'never'
          row[@runnable_start_column[runnable], 3] = [assess_completed, assess_percent, last_run]
        else
          row[@runnable_start_column[runnable], 3] = ['n/a', 'n/a', 'not assigned']
        end
      end
    end

    book.write stream_or_path
  end
end
