class Reports::Bundle < Reports::Excel
  def initialize(opts = {})
    super(opts)

    @runnables =  opts[:runnables]  || Investigation.published
    @report_learners = opts[:report_learners] || report_learners_for_runnables(@runnables)
    @heading_defs = []
    # stud.id, class, school, user.id, username, student name, teachers
    @column_defs = [
      Reports::ColumnDefinition.new(:title => "Student ID",         :width => 10),
      Reports::ColumnDefinition.new(:title => "Class",              :width => 20),
      Reports::ColumnDefinition.new(:title => "School",             :width => 15),
      Reports::ColumnDefinition.new(:title => "UserID",             :width => 8),
      Reports::ColumnDefinition.new(:title => "Username",           :width => 10),
      Reports::ColumnDefinition.new(:title => "Student Name",       :width => 15),
      Reports::ColumnDefinition.new(:title => "Teachers",           :width => 15),
    ]

    # sanity check the number of cells
    num_cells_needed = ((@runnables.size * 2) + @column_defs.size) * @report_learners.size
    raise Reports::Errors::TooManyCellsError if num_cells_needed > MAX_CELLS

    @runnable_start_column = {}
    @runnables.each do |runnable|
      @runnable_start_column[runnable] = @column_defs.size
      @heading_defs << Reports::ColumnDefinition.new(:title => "#{runnable.name} (#{runnable.id})", :heading_row => 0, :col_index => @column_defs.size, :width => 25)
      @column_defs << Reports::ColumnDefinition.new(:title => "Learner created at", :width => 20)
      @column_defs << Reports::ColumnDefinition.new(:title => "Bundles", :width => 4)
    end
  end

  def sorted_learners()
    @report_learners.sort_by {|l| [l.school_name, l.class_name, l.student_name, l.runnable_name]}
  end

  def run_report(stream_or_path,book=Spreadsheet::Workbook.new)
    sheet = book.create_worksheet :name => 'Usage'
    write_sheet_headers(sheet, (@column_defs + @heading_defs))
    student_learners = sorted_learners.group_by {|l| l.student_id }
    student_learners.each_key do |student_id|
      learners = student_learners[student_id]
      row = sheet.row(sheet.last_row_index + 1)
      learner_info = report_learner_info_cells(learners.first)
      row[0, learner_info.size] =  learner_info
      @runnables.each do |runnable|
        l = learners.detect {|learner| learner.runnable_type == runnable.class.to_s && learner.runnable_id == runnable.id}
        if (l)
          portal_learner = l.learner
          bundle_count = 0
          bundle_logger = portal_learner.bundle_logger
          bundle_count = bundle_logger.bundle_contents.count if bundle_logger

          row[@runnable_start_column[runnable], 2] = [portal_learner.created_at.to_s, bundle_count]
        else
          row[@runnable_start_column[runnable], 2] = ['no learner', 'n/a']
        end
      end
    end

    book.write stream_or_path
  end
end