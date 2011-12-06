class Reports::Detail < Reports::Excel

  def initialize(opts = {})
    super(opts)

    @investigations = opts[:investigations] || Investigation.published
    @report_learners = opts[:report_learners] || report_learners_for_runnables(@investigations)

    # stud.id, class, school, user.id, username, student name, teachers, completed, %completed, last_run
    @common_columns = [
      Reports::ColumnDefinition.new(:title => "Student ID",   :width => 10),
      Reports::ColumnDefinition.new(:title => "Class",        :width => 25),
      Reports::ColumnDefinition.new(:title => "School",       :width => 25),
      Reports::ColumnDefinition.new(:title => "UserID",       :width => 25),
      Reports::ColumnDefinition.new(:title => "Username",     :width => 25),
      Reports::ColumnDefinition.new(:title => "Student Name", :width => 25),
      Reports::ColumnDefinition.new(:title => "Teachers",     :width => 50),
      Reports::ColumnDefinition.new(:title => "Assessments Completed", :width => 4, :left_border => true),
      Reports::ColumnDefinition.new(:title => "% Completed", :width => 4),
      Reports::ColumnDefinition.new(:title => "Last run",    :width => 20),
    ]
  end

  def sorted_learners()
    @report_learners.sort_by {|l| [l.school_name, l.class_name, l.student_name, l.runnable_name]}
  end

  def setup_sheet_for_investigation(inv)
      # Spreadhseet was dying on ":" and  "/" chars. Others?
      sheet_name = inv.name.gsub /[^a-zA-z0-9 ]/,"_"
      sheet_name = sheet_name[0..30]
      @inv_sheet[inv] = @book.create_worksheet :name => sheet_name
      sheet_defs = @common_columns.clone
      answer_defs = []
      header_defs = [] # top level header:  Investigation
      activities = inv.activities.student_only
      # offset the reportables counter by 2
      reportable_header_counter = sheet_defs.size
      header_defs << Reports::ColumnDefinition.new(:title => sheet_name, :heading_row => 0, :col_index => reportable_header_counter)
      activities.each do |a|
        header_defs << Reports::ColumnDefinition.new(:title => a.name, :width=> 30, :heading_row => 0, :col_index => reportable_header_counter)
        reportable_header_counter += 2 # (two columns per activity header)
      end
      reportable_header_counter -= 1

      # Itterate Activities
      activities.each do |a|
        sheet_defs << Reports::ColumnDefinition.new(:title => "#{a.name}\nAssessments Completed", :width => 4, :left_border => true)
        sheet_defs << Reports::ColumnDefinition.new(:title => "% Completed", :width => 4)
        reportables = a.reportable_elements.map {|re| re[:embeddable]}
        first = true

        # Itterate Reportables
        reportables.each do |r|
          reportable_header_counter += 1
          header_defs << Reports::ColumnDefinition.new(:title => a.name, :heading_row => 0, :col_index => reportable_header_counter)
          answer_defs << Reports::ColumnDefinition.new(:title => clean_text((r.respond_to?(:prompt) ? r.prompt : r.name)), :width => 25, :left_border => first)
          first = false
        end # reportables
      end #activities

      col_defs = sheet_defs + answer_defs + header_defs
      write_sheet_headers(@inv_sheet[inv], col_defs)
  end

  def run_report(stream_or_path, work_book = Spreadsheet::Workbook.new)
    @book = work_book
    @inv_sheet = {}
    @investigations.sort!{|a,b| a.name <=> b.name}

    print "Creating #{@investigations.size} worksheets for report" if @verbose
    @investigations.each do |inv|
      setup_sheet_for_investigation(inv)
    end # investigations
    puts " done." if @verbose

    student_learners = sorted_learners.group_by {|l| l.student_id }

    print "Filling in student data" if @verbose
    iterate_with_status(student_learners.keys) do |student_id|
      student_learners[student_id].each do |l|
        next unless (inv = @investigations.detect{|i| i.id == l.runnable_id}) # ??? FIXME: We're assuming that the runnable on Report::Learner is always an investigation

        # <=================================================>
        total_assessments = l.num_answerables
        assess_completed = l.num_answered
        # <=================================================>
        total_by_activity = inv.activities.inject(0) { |a,b| a + b.reportable_elements.size}
        assess_percent = percent(assess_completed, total_assessments)
        last_run = l.last_run || 'never'

        sheet = @inv_sheet[inv]
        row = sheet.row(sheet.last_row_index + 1)
        assess_completed = "#{assess_completed}/#{total_assessments}(#{total_by_activity})"
        row[0, 3] =  report_learner_info_cells(l) + [assess_completed, assess_percent, last_run]

        all_answers = []
        inv.activities.student_only.each do |a|
          # <=================================================>
          reportables = a.reportable_elements.map {|re| re[:embeddable]}
          answers = reportables.map{|r| l.answers["#{r.class.to_s}|#{r.id}"] || {:answered => false, :answer => "not answered"} }
          #Bellow is bad, it gets the answers in the wrong order!
          #answers = @report_utils[l.offering].saveables(:learner => l, :embeddables => reportables )
          answered_answers = answers.select{|s| s[:answered] }
          # <=================================================>
          # TODO: weed out answers with no length, or which are empty
          row.concat [answered_answers.size, percent(answered_answers.size, reportables.size)]
          all_answers += answers.collect{|ans|
            if ans[:answer].kind_of?(Hash) && ans[:answer][:type] == "Dataservice::Blob"
              blob = ans[:answer]
              url = "#{@blobs_url}/#{blob[:id]}/#{blob[:token]}.#{blob[:file_extension]}"
              Spreadsheet::Link.new url, url
            else
              ans[:answer]
            end
          }
        end
        row.concat all_answers
      end
    end
    @book.write stream_or_path
  end

end
