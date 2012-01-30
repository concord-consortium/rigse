class Reports::Bundle < Reports::Excel

  class CellRunner
    attr_accessor :portal_learner, :bundle, :runnable, :console_logs, :events

    def run(get_value)
      self.instance_eval(&get_value)
    end
  end

  def add_col(title, width, &get_value)
    @column_defs << Reports::ColumnDefinition.new(:title => title, :width => width)
    @cell_fillers << get_value
  end

  def initialize(opts = {})
    super(opts)

    @cell_fillers = []

    @runnables =  opts[:runnables]  || Investigation.published
    @report_learners = opts[:report_learners] || report_learners_for_runnables(@runnables)
    # stud.id, class, school, user.id, username, student name, teachers
    @column_defs = [
      Reports::ColumnDefinition.new(:title => "Student ID",             :width => 10),
      Reports::ColumnDefinition.new(:title => "Class",                  :width => 20),
      Reports::ColumnDefinition.new(:title => "School",                 :width => 15),
      Reports::ColumnDefinition.new(:title => "UserID",                 :width => 8),
      Reports::ColumnDefinition.new(:title => "Username",               :width => 10),
      Reports::ColumnDefinition.new(:title => "Student Name",           :width => 15),
      Reports::ColumnDefinition.new(:title => "Teachers",               :width => 15),
    ]

    add_col("Runnable Name",          15) {runnable.name }
    add_col("ID Runnable",             6) {runnable.id}
    add_col("ID Learner",              6) {portal_learner.id}
    add_col("Learner created at",     20) {portal_learner.created_at}

    add_col("Bundle created at",      20) {bundle.created_at if bundle}

    # this come from the bundle itself
    add_col("Bundle start",           20) {bundle.session_start if bundle}
    add_col("Bundle stop",            20) {bundle.session_stop if bundle}
    add_col("Previous Session ID",    20) {bundle.previous_session_uuid if bundle}
    add_col("Session ID",             20) {bundle.session_uuid if bundle}
    add_col("Local IP",               15) {bundle.local_ip if bundle}
    add_col("Otml bytes",             10) {bundle.otml.length if bundle}
    add_col("Otml hash",              20) {bundle.otml_hash if bundle}

    # this will come from the server launch process events
    # note these currently don't track actual sessions so parrallel sessions will
    #  create strange data
    add_col("session started",        20) {events.find_by_event_type("session started").created_at if events }
    add_col("jnlp requested",         20) {events.find_by_event_type("jnlp requested").created_at if events }
    add_col("logo image requested",   20) {events.find_by_event_type("logo image requested").created_at if events }
    add_col("config requested",       20) {events.find_by_event_type("config requested").created_at if events }
    add_col("bundle requested",       20) {events.find_by_event_type("bundle requested").created_at if events }
    add_col("activity otml requested",20) {events.find_by_event_type("activity otml requested").created_at if events }
    add_col("bundle saved",           20) {events.find_by_event_type("bundle saved").created_at if events }

    # consoles for same session id
    add_col("# Consoles",              4) {console_logs.map{|log| log.session_uuid}.count(bundle.session_uuid) if console_logs && bundle}

    # sanity check the number of cells
    # HACK: assume an average of 2 bundles per learner
    num_cells_needed =  @column_defs.size * @report_learners.size * 2
    raise Reports::Errors::TooManyCellsError if num_cells_needed > MAX_CELLS
  end

  def sorted_learners()
    @report_learners.sort_by {|l| [l.school_name, l.class_name, l.student_name, l.runnable_name]}
  end

  def run_report(stream_or_path,book=Spreadsheet::Workbook.new)
    sheet = book.create_worksheet :name => 'Bundle'
    cell_runner = CellRunner.new
    write_sheet_headers(sheet, @column_defs )
    # the learner_id function in the super class returns a string of the [student_id]_[class_id]
    student_learners = sorted_learners.group_by {|l| learner_id(l) }
    student_learners.each_key do |student_class_id|
      learners = student_learners[student_class_id]
      @runnables.each do |runnable|
        learner = learners.detect {|learner| learner.runnable_type == runnable.class.to_s && learner.runnable_id == runnable.id}
        next unless learner  # in this bundle report we don't need to show un created learners
        portal_learner = learner.learner
        bundle_logger = portal_learner.bundle_logger
        console_logger = portal_learner.console_logger
        bundles = []
        if(bundle_logger.nil? || bundle_logger.bundle_contents.count == 0)
          # create a row to represent just the learner
          bundles = [nil]
        else
          bundles = bundle_logger.bundle_contents
        end

        bundles.each { |bundle|
          row = sheet.row(sheet.last_row_index + 1)
          learner_info = report_learner_info_cells(learners.first)
          row[0, learner_info.size] = learner_info
          cell_runner.runnable = runnable
          cell_runner.portal_learner = portal_learner
          cell_runner.bundle = bundle
          cell_runner.console_logs = console_logger.console_contents

          @cell_fillers.each { |filler|
            # might need a & here
            row[row.length] = cell_runner.run(filler)
          }
        }
      end
    end

    book.write stream_or_path
  end
end