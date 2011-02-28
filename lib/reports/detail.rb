class Reports::Detail < Reports::Excel

  def initialize(opts = {})
    super(opts)

    @investigations = opts[:investigations] || Investigation.published
  
    # stud.id, class, school, user.id, username, student name, teachers, completed, %completed, last_run
    @common_columns = [
      Reports::ColumnDefinition.new(:title => "Student ID",   :width => 10),
      Reports::ColumnDefinition.new(:title => "Class",        :width => 25),
      Reports::ColumnDefinition.new(:title => "School",       :width => 25),
      Reports::ColumnDefinition.new(:title => "UserID",     :width => 25),
      Reports::ColumnDefinition.new(:title => "Username",     :width => 25),
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
    @investigations.sort!{|a,b| a.name <=> b.name}
    @investigations.each do |inv|
      # puts "Investigation #{"%4d" % inv.id}"
      @inv_sheet[inv] = book.create_worksheet :name => inv.name
      sheet_defs = @common_columns.clone
      answer_defs = []
      header_defs = [] # top level header:  Investigation
      activities = inv.activities.student_only
      # offset the reportables counter by 2 
      reportable_header_counter = sheet_defs.size
      header_defs << Reports::ColumnDefinition.new(:title => inv.name, :heading_row => 0, :col_index => reportable_header_counter)
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
    end # investigations

    puts " done." if @verbose

    @report_utils = {}  # map of offerings to Report::Util objects
    students = Portal::Student.all
    # remove bougs students
    students.reject! { |s| s.user.nil? || s.user.default_user || s.learners.size==0 }

    # sort by school and last
    students.sort!{ |a,b| 
      if school_name_for(a) !=  school_name_for(b)
        school_name_for(a)  <=> school_name_for(b)
      else
        a.user.last_name <=> b.user.last_name
      end
    }

    iterate_with_status(students) do |student|
      learners = student.learners
      learners.reject! { |l| l.offering.nil? || l.offering.clazz.nil? || l.offering.runnable.nil? }
      learners.sort! { |a,b| 
        aname = a.offering.clazz.name || "No Class Name"
        bname = b.offering.clazz.name || "No Class Name"
        aname <=> bname
      }
      learners.each do |l|
        inv = l.offering.runnable
        next unless @investigations.include?(inv)

        @report_utils[l.offering] ||= Report::Util.new(l.offering)
        clazz = l.offering.clazz
        school = clazz.school
        school_name = school ? school.name || "school: #{school.id}" : "no school <error?>"
        teachers = clazz.teachers.flatten.compact.uniq.map{|t| t.name }.join(",")

        total_assessments = @report_utils[l.offering].embeddables.size
        assess_completed = @report_utils[l.offering].saveables({:learner => l}).select{|s| s.answered? }.size
        assess_percent = percent(assess_completed, total_assessments)
        last_run = l.bundle_logger.bundle_contents.compact.last
        last_run = last_run.nil? ? 'never' : last_run.created_at

        sheet = @inv_sheet[inv]
        row = sheet.row(sheet.last_row_index + 1)
        student_name = "#{student.user.last_name}, #{student.user.first_name}"
        student_id = "#{student.id}_#{clazz.id}" # unique id as per https://www.pivotaltracker.com/story/show/8904471
        # stud.id, class, school, user.id, username, student name, teachers, completed, %completed, last_run
        row[0, 3] = [student_id, clazz.name, school_name, student.user.id, student.user.login, student_name, teachers, assess_completed, assess_percent, last_run]

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
