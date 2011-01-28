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

  def run_report(stream_or_path)
    book = Spreadsheet::Workbook.new

    sheet1 = book.create_worksheet :name => 'Usage'
    write_sheet_headers(sheet1, @column_defs)

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
      row = sheet1.row(sheet1.last_row_index + 1)
      user = student.user
      student_name = "#{user.last_name}, #{user.first_name}"
      clazzes = student.clazzes.sort do |a,b| 
        aname = a.name || "No Class Name"
        bname = b.name || "No Class Name"
        aname <=> bname
      end
      clazzes.each do |clazz|
        actually_wrote_data = false
        student_id  = "#{student.id}_#{clazz.id}" # unique id as per https://www.pivotaltracker.com/story/show/8904471 clazz_name = clazz.name || "Class: #{clazz.id}" school = clazz.schol
        school      = clazz.school
        class_name  = clazz.name || "class: #{clazz.id}"
        school_name = school.nil? ? "No School" : (school.name || "School: #{school.id}")
        teachers    = clazz.teachers.compact.uniq.map{|t| t.name}.join(",")
        learners    = student.learners
        learners.reject! { |l| l.offering.nil? || l.offering.clazz.nil? || l.offering.runnable.nil? }
        learners.reject! { |l| ever_offered_for(clazz).include? l.offering}
        learners.each do |l|
          inv = l.offering.runnable
          next unless @investigations.include?(inv)
          @report_utils[l.offering] ||= Report::Util.new(l.offering)
          total_assessments = @report_utils[l.offering].embeddables.size
          assess_completed = @report_utils[l.offering].saveables({:learner => l}).select{|s| s.answered? }.size
          assess_percent = percent(assess_completed, total_assessments)
          last_run = l.bundle_logger.bundle_contents.compact.last
          last_run = last_run.nil? ? 'never' : last_run.created_at
          row[@inv_start_column[inv], 3] = [assess_completed, assess_percent, last_run]
          actually_wrote_data = true
        end
        if actually_wrote_data
          # stud.id, class, school, user.id, username, student name, teachers
          row[0,7] = [student_id, class_name, school_name, user.id, user.login, student_name, teachers]
        else
          row[0,8] = [student_id, class_name, school_name, user.id, user.login, student_name, teachers, 0, 0, 'never']
        end
      end
    end

    book.write stream_or_path
  end
end
