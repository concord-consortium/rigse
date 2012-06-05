class Reports::ConcludingCareerStem < Reports::Excel
  def initialize(opts = {})
    super(opts)

    @cols_per_sheet = 245
    @runnables = opts[:runnables] || Activity.published
    @report_learners = opts[:report_learners] || report_learners_for_runnables(@runnables)

    @student_learners = sorted_learners.group_by {|l| l.student_id }

    @reportables_by_runnable = {}

    @common_columns = [
      Reports::ColumnDefinition.new(:title => "Student IDs",  :width => 10),
      Reports::ColumnDefinition.new(:title => "Classes",      :width => 25),
      Reports::ColumnDefinition.new(:title => "Schools",      :width => 25),
      Reports::ColumnDefinition.new(:title => "UserID",       :width => 25),
      Reports::ColumnDefinition.new(:title => "Username",     :width => 25),
      Reports::ColumnDefinition.new(:title => "Student Name", :width => 25),
      Reports::ColumnDefinition.new(:title => "Teachers",     :width => 50),
    ]

    # Sanity checks
    while max_cells_required > MAX_CELLS && @cols_per_sheet > (245/5)
      @cols_per_sheet -= 20
    end
    raise Reports::Errors::TooManyCellsError if max_cells_required > MAX_CELLS

    num_sheets_required = (@runnables.size/@cols_per_sheet.to_f).ceil
    raise Reports::Errors::TooManySheetsError if num_sheets_required > MAX_SHEETS
  end

  def max_cells_required
    max_cols_required = (@runnables.size > @cols_per_sheet ? (@cols_per_sheet) : @runnables.size) + @common_columns.size
    max_cells_required = max_cols_required * @student_learners.size
  end

  def sorted_learners
    @report_learners.sort_by {|l| [l.school_name, l.class_name, l.student_name, l.runnable_name]}
  end

  def create_sheet(runnables, count)
    sheet = @book.create_worksheet :name => "Career STEM #{count}"
    header_defs = @common_columns.clone
    container_header_defs = [] # top level header

    header_col_idx = header_defs.size
    runnables.each do |r|
      if reportables = get_concluding_stem_questions(r)
        first = true
        reportables.each do |rep|
          container_header_defs << Reports::ColumnDefinition.new(:title => r.name, :width=> 30, :heading_row => 0, :col_index => header_col_idx)
          header_defs << Reports::ColumnDefinition.new(:title => clean_text((rep.respond_to?(:prompt) ? rep.prompt : rep.name)), :width => 25, :left_border => first)
          header_col_idx += 1 # (one column per container)
          first = false
        end
      end
    end

    col_defs = header_defs + container_header_defs
    write_sheet_headers(sheet, col_defs)

    # fill in the common student data
    first_row = sheet.last_row_index + 1

    # first fill in all the student's info
    current_row = first_row
    @student_learners.each do |student_id, learners|
      # FIXME This won't provide an accurate list of student teachers and classes!
      sheet.row(current_row).concat report_learner_info_cells(learners)[0..(@common_columns.size-1)]
      current_row += 1
    end
    return sheet
  end

  def run_report(stream_or_path, work_book = Spreadsheet::Workbook.new)
    @book = work_book
    @book.create_worksheet :name => 'Empty' if @runnables.empty?

    print "Sorting runnables..." if @verbose
    @runnables.sort!{|a,b| a.name <=> b.name}
    @runnables_by_id = {}
    @runnables.each{|r| @runnables_by_id["#{r.class.to_s}|#{r.id}"] = r }
    puts " done." if @verbose

    ############### SHEET SETUP ########################
    print "Setting up sheets..." if @verbose
    @sheets = {} # keys are arrays of runnables, value is the sheet they should go on
    range_start = 0
    range_end = (@cols_per_sheet-1)
    count = 0
    while range_start < @runnables.size
      range_end = (@runnables.size - 1) if range_end >= @runnables.size
      set = @runnables[range_start..range_end]
      @sheets[set] = create_sheet(set, count += 1)
      range_start += @cols_per_sheet
      range_end += @cols_per_sheet
    end
    puts " done." if @verbose

    ############### STUDENT ANSWERS ########################
    print "Filling in student data... " if @verbose
    fill_in_col_by_col
    puts " done." if @verbose
    print "Writing out workbook... " if @verbose
    @book.write stream_or_path
    puts " done." if @verbose
    return @book
  end

  def fill_in_col_by_col
    first_row = 2
    # now fill in their answers
    @sheets.each do |runnables, sheet|
      col_idx = @common_columns.size
      iterate_with_status(runnables) do |runnable|
        if reportables = get_concluding_stem_questions(runnable)
          reportables.each do |rep|
            # for every student, enter the student's answer into the sheet
            current_row = first_row
            @student_learners.each do |student_id, learners|
              if learner = learners.detect{|l| l.runnable_id == runnable.id && l.runnable_type == runnable.class.to_s }
                answer = get_concluding_stem_answer(rep, learner)
                sheet.row(current_row)[col_idx, 1] = answer
              end
              current_row += 1
            end
            col_idx += 1
          end
        end
      end
    end
  end

  def get_concluding_stem_questions(runnable)
    return @reportables_by_runnable[runnable] if @reportables_by_runnable[runnable]
    @reportables_by_runnable[runnable] = []
    if runnable.kind_of?(Activity)
      stem_pages = runnable.pages.select{|p| (p.name == "Second Career STEM Question" || p.name == "Concluding Career STEM Question") }
      @reportables_by_runnable[runnable] = stem_pages.map{|p| p.reportable_elements.map{|re| re[:embeddable]} }.flatten
    end
    return @reportables_by_runnable[runnable]
  end

  def get_concluding_stem_answer(stem_question, report_learner)
    answer_obj = report_learner[:answers]["#{stem_question.class.to_s}|#{stem_question.id.to_s}"] || {:answer => nil}
    return answer_obj[:answer]
  end

  def report_learner_info_cells(report_learners)
    return [
      report_learners.map{|rl| learner_id(rl) }.uniq.join(","),
      report_learners.map{|rl| rl.class_name }.uniq.join(","),
      report_learners.map{|rl| rl.school_name }.uniq.join(","),
      user_id(report_learners[0]),
      report_learners[0].username,
      report_learners[0].student_name,
      report_learners.map{|rl| rl.teachers_name }.uniq.join(",")
    ]
  end
end
