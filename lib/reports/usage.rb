class Reports::Usage < Reports::Excel
  def initialize(opts = {})
    super(opts)

    @runnables =  opts[:runnables]  || Investigation.published
    @report_learners = opts[:report_learners] || report_learners_for_runnables(@runnables)
    @include_child_usage = opts[:include_child_usage]
    #@column_defs = [
      #Reports::ColumnDefinition.new(:title => "Student ID",   :width => 10 ),
      #Reports::ColumnDefinition.new(:title => "Student Name", :width => 25 ),
      #Reports::ColumnDefinition.new(:title => "Teachers",     :width => 50 )
    #]
    # stud.id, class, school, user.id, username, student name, teachers
    @shared_column_defs = [
      Reports::ColumnDefinition.new(:title => "Student ID",   :width => 10),
      Reports::ColumnDefinition.new(:title => "Class",        :width => 25),
      Reports::ColumnDefinition.new(:title => "School",       :width => 25),
      Reports::ColumnDefinition.new(:title => "UserID",       :width => 25),
      Reports::ColumnDefinition.new(:title => "Username",     :width => 25),
      Reports::ColumnDefinition.new(:title => "Student Name", :width => 25),
      Reports::ColumnDefinition.new(:title => "Teachers",     :width => 50),
    ]
    
    @runnable_start_column = {}
    @sheet_defs = [[]]
    @runnables.each do |runnable|
      col_defs = @sheet_defs.last
      @runnable_start_column[runnable] = {:sheet => (@sheet_defs.size - 1), :column => (col_defs.size + @shared_column_defs.size)}
      col_defs << Reports::ColumnDefinition.new(:title => "#{runnable.name} (#{runnable.id})\nAssessments Completed", :width => 4, :left_border => :thin)
      col_defs << Reports::ColumnDefinition.new(:title => "% Completed", :width => 4)
      col_defs << Reports::ColumnDefinition.new(:title => "Last run",    :width => 20)
      if @include_child_usage
        children = (get_containers(runnable) - [runnable])
        children.each do |child|
          col_defs << Reports::ColumnDefinition.new(:title => "#{child.name} (#{child.id})\nAssessments Completed", :width => 4)
          col_defs << Reports::ColumnDefinition.new(:title => "% Completed", :width => 4)
        end
      end
      @sheet_defs << [] if (col_defs.size + @shared_column_defs.size) > 250
    end
  end

  def sorted_learners()
    @report_learners.sort_by {|l| [l.school_name, l.class_name, l.student_name, l.runnable_name]}
  end

  def run_report(stream_or_path,book=Spreadsheet::Workbook.new)
    @sheets = []
    print "Creating #{@sheet_defs.size} worksheets for report" if @verbose
    @sheet_defs.each_with_index do |s_def, i|
      sheet = book.create_worksheet :name => "Usage #{i+1}"
      write_sheet_headers(sheet, @shared_column_defs + s_def)
      @sheets << sheet
    end
    puts " done." if @verbose

    puts "Filling in student data" if @verbose
    student_learners = sorted_learners.group_by {|l| l.student_id }
    iterate_with_status(student_learners.keys) do |student_id|
      learners = student_learners[student_id]
      learner_info = report_learner_info_cells(learners.first)
      rows = []
      @sheets.each do |sheet|
        row = sheet.row(sheet.last_row_index + 1)
        row[0, learner_info.size] =  learner_info
        rows << row
      end
      @runnables.each do |runnable|
        l = learners.detect {|learner| learner.runnable_type == runnable.class.to_s && learner.runnable_id == runnable.id}
        row = rows[@runnable_start_column[runnable][:sheet]]
        if (l)
          total_assessments = l.num_answerables
          assess_completed =  l.num_answered
          assess_percent = percent(assess_completed, total_assessments)
          last_run = l.last_run || 'never'
          row_vals = [assess_completed, assess_percent, last_run]
          if @include_child_usage
            children = (get_containers(runnable) - [runnable])
            children.each do |child|
              reportables = child.reportable_elements.map {|re| re[:embeddable] }
              answers = reportables.map{|r| l.answers["#{r.class.to_s}|#{r.id}"] || {:answered => false, :answer => "not answered"} }
              answered_answers = answers.select {|a| a[:answered] }.size
              row_vals << answered_answers
              row_vals << percent(answered_answers, reportables.size)
            end
          end

          row[@runnable_start_column[runnable][:column], 3] = row_vals
        else
          # The spreadsheet gem doesn't handle tons of strings well,
          # so let's just leave these blank for now
#          row_vals = ['n/a', 'n/a', 'not assigned']
#          if @include_child_usage
#            children = (get_containers(runnable) - [runnable])
#            children.each do |child|
#              row_vals << 'n/a'
#              row_vals << 'n/a'
#            end
#          end
#          row[@runnable_start_column[runnable][:column], 3] = row_vals
        end
      end
    end

    print "Writing xls file..." if @verbose
    book.write stream_or_path
    print " done." if @verbose
  end
end
