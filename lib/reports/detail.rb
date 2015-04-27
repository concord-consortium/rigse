class Reports::Detail < Reports::Excel

  def initialize(opts = {})
    super(opts)

    @runnables = opts[:runnables] || Investigation.published
    @report_learners = opts[:report_learners] || report_learners_for_runnables(@runnables)

    # stud.id, class, school, user.id, username, student name, teachers, completed, %completed, last_run
    @common_columns = common_header + [
      Reports::ColumnDefinition.new(:title => "# Completed", :width => 10, :left_border => :thin),
      Reports::ColumnDefinition.new(:title => "% Completed", :width => 10),
      Reports::ColumnDefinition.new(:title => "# Correct",   :width => 10),
      Reports::ColumnDefinition.new(:title => "Last run",    :width => 20)
    ]

    @reportable_embeddables = {} # keys will be runnables, and value will be an array of reportables for that runnable, in the correct order
  end

  def sorted_learners()
    @report_learners.sort_by {|l| [l.school_name, l.class_name, l.student_name, l.runnable_name]}
  end

  def setup_sheet_for_runnable(runnable)
      # Spreadhseet was dying on ":" and  "/" chars. Others?
      sheet_name = runnable.name.gsub /[^a-zA-z0-9 ]/,"_"
      sheet_name = sheet_name[0..30]
      sheet_name "Unknown" unless sheet_name && sheet_name.size > 0
      @runnable_sheet[runnable] = @book.create_worksheet :name => sheet_name
      sheet_defs = @common_columns.clone
      answer_defs = []
      header_defs = [] # top level header
      expected_answers = []

      # save the original assignable so we can refer to it later
      assignable = runnable
      if runnable.is_a?(::ExternalActivity)
        if runnable.template
          runnable = runnable.template
        else
          # we can't report on external activities that don't have templates
          return
        end
      end

      # This needs to account for varying types of runnables...
      containers = get_containers(runnable)

      # offset the reportables counter by 2
      reportable_header_counter = sheet_defs.size
      header_defs << Reports::ColumnDefinition.new(:title => sheet_name, :heading_row => 0, :col_index => reportable_header_counter)
      containers.each do |a|
        header_defs << Reports::ColumnDefinition.new(:title => a.name, :width=> 30, :heading_row => 0, :col_index => reportable_header_counter)
        reportable_header_counter += 2 # (two columns per container header)
      end
      reportable_header_counter -= 1

      # Iterate containers
      containers.each do |a|
        sheet_defs << Reports::ColumnDefinition.new(:title => "#{a.name}\nAssessments Completed", :width => 4, :left_border => :thin)
        sheet_defs << Reports::ColumnDefinition.new(:title => "% Completed", :width => 4)

        reportable_header_counter = setup_sheet_runnables(a, reportable_header_counter, header_defs, answer_defs, expected_answers)
      end #containers

      col_defs = sheet_defs + answer_defs + header_defs
      write_sheet_headers(@runnable_sheet[assignable], col_defs)

      # Add row with expected answers.
      expected_answers.map! { |a| a.nil? ? "" : a }
      row = @runnable_sheet[assignable].row(@runnable_sheet[assignable].last_row_index + 1)
      row.concat(expected_answers)
  end

  def setup_sheet_runnables(container, reportable_header_counter, header_defs, answer_defs, expected_answers)
    reportables = container.reportable_elements.map {|re| re[:embeddable]}
    first = true
    question_counter = 0
    # Iterate Reportables
    reportables.each do |r|
      question_counter += 1
      reportable_header_counter += 1
      header_defs << Reports::ColumnDefinition.new(:title => container.name, :heading_row => 0, :col_index => reportable_header_counter)
      title = clean_text((r.respond_to?(:prompt) ? r.prompt : r.name))
      title = "#{question_counter}: #{title}"
      answer_defs << Reports::ColumnDefinition.new(:title => title, :width => 25, :left_border => (first ? :thin : :none))
      expected_answers[reportable_header_counter] = get_expected_answer(r)
      if r.is_a?(Embeddable::ImageQuestion)
        reportable_header_counter += 1
        answer_defs << Reports::ColumnDefinition.new(:title => 'note', :width => 25, :left_border => :none)
      end
      if r.is_required?
        reportable_header_counter += 1
        answer_defs << Reports::ColumnDefinition.new(:title => 'submitted', :width => 10, :left_border => :none)
      end
      first = false
    end # reportables
    return reportable_header_counter
  end

  def run_report(stream_or_path, work_book = Spreadsheet::Workbook.new)
    @book = work_book
    @runnable_sheet = {}
    @runnables.sort!{|a,b| a.name <=> b.name}

    print "Creating #{@runnables.size} worksheets for report" if @verbose
    @runnables.each do |runnable|
      setup_sheet_for_runnable(runnable)
    end # runnables
    puts " done." if @verbose

    student_learners = sorted_learners.group_by {|l| [l.student_id,l.class_id] }

    print "Filling in student data" if @verbose
    iterate_with_status(student_learners.keys) do |student_class|
      student_id = student_class[0]
      student_learners[student_class].each do |l|
        next unless (runnable = @runnables.detect{|r| l.runnable_type == r.class.to_s && r.id == l.runnable_id})
        # sheets are indexed from the actual runnable
        sheet = @runnable_sheet[runnable]
        if runnable.is_a?(::ExternalActivity)
          if runnable.template
            runnable = runnable.template
          else
            # we can't report on external activities that don't have templates
            next
          end
        end

        correctable = runnable.reportable_elements.select {|r| r[:embeddable].respond_to? :correctable? }
        # <=================================================>
        total_assessments = l.num_answerables
        assess_completed = l.num_submitted
        # <=================================================>
        total_by_container = get_containers(runnable).inject(0) { |a,b| a + b.reportable_elements.size}
        assess_percent = percent(assess_completed, total_assessments)
        last_run = l.last_run || 'never'

        row = sheet.row(sheet.last_row_index + 1)
        assess_completed = "#{assess_completed}/#{total_assessments}(#{total_by_container})"
        assess_correct = "#{l.num_correct}/#{correctable.size}"
        row[0, 3] =  report_learner_info_cells([l]) + [assess_completed, assess_percent, assess_correct, last_run]

        all_answers = []
        get_containers(runnable).each do |container|
          # <=================================================>
          reportables = container.reportable_elements.map { |re| re[:embeddable] }
          answers = reportables.map { |r| l.answers["#{r.class.to_s}|#{r.id}"] || default_answer_for(r) }
          #Bellow is bad, it gets the answers in the wrong order!
          #answers = @report_utils[l.offering].saveables(:learner => l, :embeddables => reportables )
          # s[:submitted] may be nil, as this hash key was added much later. Previously there was no notion
          # of submitted question, they were only answered or not. In theory we could add DB migration that
          # would update this hash (see answers attribute in Report::Learner), but that would be non-trivial
          # and migration itself would be very time consuming (I've done some experiments in console).
          submitted_answers = answers.select { |s| s[:submitted].nil? ? s[:answered] : s[:submitted] }
          correct_answers  = answers.select { |s| s[:is_correct] }
          # <=================================================>
          # TODO: weed out answers with no length, or which are empty
          row.concat [submitted_answers.size, percent(submitted_answers.size, reportables.size)]
          all_answers += answers.collect { |ans|
            res = nil
            if ans[:answer].kind_of?(Hash) && ans[:answer][:type] == "Dataservice::Blob"
              blob = ans[:answer]
              if blob[:id] && blob[:token]
                url = "#{@blobs_url}/#{blob[:id]}/#{blob[:token]}.#{blob[:file_extension]}"
                res = [Spreadsheet::Link.new(url, url), (ans[:answer][:note] || "")]
              else
                res = ["not answered", ""]
              end
            else
              answer_value = ans[:answer].kind_of?(Enumerable) ? ans[:answer].map { |a| a[:answer] }.join(', ') : ans[:answer]
              case ans[:is_correct]
                when true then res = ["(correct) #{answer_value}"]
                when nil then res = [answer_value]
                when false then res = ["(wrong) #{answer_value}"]
              end
            end
            res << (ans[:submitted] ? "yes" : "no") if ans[:question_required]
            res
          }.flatten
        end
        row.concat all_answers
      end
    end
    @book.write stream_or_path
  end

  def default_answer_for(embeddable)
    if embeddable.is_a?(Embeddable::ImageQuestion)
      return {:answered => false, :answer => {:type => "Dataservice::Blob"}, :submitted => false, :question_required => embeddable.is_required }
    end
    return {:answered => false, :answer => "not answered", :submitted => false, :question_required => embeddable.is_required }
  end

  def get_expected_answer(reportable)
    ans = reportable.respond_to?(:correct_answer) ? reportable.correct_answer : ""
    ans.blank? ? "" : "expected: #{ans}"
  end
end
