class Reports::Excel
  require 'spreadsheet'
  require 'nokogiri' # text sanitization ...

  def initialize(opts = {})
    @verbose = !!opts[:verbose]
    @blobs_url =  opts[:blobs_url] || "<specify blobs host>"
    STDOUT.sync = true if @verbose
  end

  protected

  def iterate_with_status(objects, &block)
    class_str = objects.first.class.to_s
    class_str = class_str.pluralize if objects.size > 1
    puts "Processing #{objects.size} #{class_str} ...\n" if @verbose
    reset_status
    objects.each do |o|
      print_status
      yield o
    end
    puts " done." if @verbose
  end

  def write_sheet_headers(sheet, column_defs)
    column_defs.each do |col|
      col.write_header(sheet)
    end
  end

  def percent(completed, total)
    percent = "n/a"
    percent = (((completed.to_f / total.to_f) * 100).round.to_s + "%") unless total == 0
    return percent
  end

  def print_status
    return unless @verbose
    @count ||= 0
    print "\n#{"%4d" % @count}: " if @count % 50 == 0
    print "."
    @count += 1
  end

  def reset_status
    @count = 0
  end

  def clean_text(html)
    return Nokogiri::HTML(html).inner_text
  end

  # Return a list of offerings
  # that have ever been run for a clazz
  # this is to support removed offerings
  #def ever_offered_for(clazz)
    #key = "clazz_#{clazz.id}"
    #@class_offering_map ||= {}
    #result =  @class_offering_map[key]
    #unless result
      #offerings = clazz.students.map {|s| s.learners.map {|l| l.offering}}.flatten.uniq
      #result = @class_offering_map[key] = offerings
    #end
    #result
  #end

  def all_students_sorted
    students = Portal::Student.all
    # remove bougs students
    students.reject! { |s| s.user.nil? || s.user.default_user || s.learners.size==0 }
    sorted_students(students)
  end

  # take a list of runnables, and return a list of students.
  def sorted_students_for_runnables(runnables)
    runnables = [runnables] unless runnables.respond_to? :count
    offerings = runnables.map { |i| i.offerings }.flatten.uniq.compact
    students  = offerings.map {|o| o.learners}.flatten.compact.map {|l| l.student}.compact.uniq
    students  = sorted_students(students)
  end

  def report_learners_for_runnables(runnables)
    runnables = [runnables] unless runnables.respond_to? :count
    offerings = runnables.map { |i| i.offerings }.flatten.uniq.compact
    learners = offerings.map {|o| o.learners}.flatten.compact
    learners.map {|l| l.report_learner }
  end

  def sorted_students(students)
    # sort by school and last
    students.sort{ |a,b|
      if school_name_for(a) !=  school_name_for(b)
        school_name_for(a)  <=> school_name_for(b)
      else
        a.user.last_name <=> b.user.last_name
      end
    }
  end

  def sorted_learners(student)
    learners = student.learners
    learners.reject! { |l| l.offering.nil? || l.offering.clazz.nil? || l.offering.runnable.nil? }
    learners.sort! { |a,b|
      aname = clazz_name_for(a.offering)
      bname = clazz_name_for(b.offering)
      aname <=> bname
    }
  end

  def school_name_for(thing)
    name = thing.school ? (thing.school.name || "School #{thing.school.name}") : "No School"
    return name
  end

  def clazz_name_for(offering)
    name = offering.clazz ? (offering.clazz.name || "Class: #{offering.clazz.id}") : "No Class"
    return name
  end
  def learner_id(learner)
    return "#{learner.student_id}_#{learner.class_id}" if learner.kind_of?(Report::Learner)
    return "#{learner.student.id}_#{learner.offering.clazz.id}"
  end

  def user_id(learner)
    return learner.user_id if learner.kind_of?(Report::Learner)
    return learner.student.user.id
  end

  def permission_forms(report_learner)
    results = report_learner.permission_forms
    results = "none" if results.blank?
    results
  end

  def learner_login(learner)
    learner.student.user.login
  end

  def learner_name(learner)
    "#{learner.student.user.first_name} #{learner.student.user.last_name}"
  end

  def report_learner_info_cells(report_learners)
    report_learner = report_learners.first

    return [
      report_learner.student_id,
      report_learners.map { |l| l.learner_id }.join(", "),
      report_learner.class_id,
      report_learner.class_name,
      report_learner.school_name,
      user_id(report_learner),
      permission_forms(report_learner),
      report_learner.username,
      report_learner.student_name,
      report_learner.teachers_name
    ]
  end

  def common_header
    return [
      Reports::ColumnDefinition.new(:title => "Student ID",    :width => 10),
      Reports::ColumnDefinition.new(:title => "Learner ID(s)", :width => 10),
      Reports::ColumnDefinition.new(:title => "Class ID",      :width => 10),
      Reports::ColumnDefinition.new(:title => "Class",         :width => 25),
      Reports::ColumnDefinition.new(:title => "School",        :width => 25),
      Reports::ColumnDefinition.new(:title => "UserID",        :width => 25),
      Reports::ColumnDefinition.new(:title => "Perm. Forms",   :width => 25),
      Reports::ColumnDefinition.new(:title => "Username",      :width => 25),
      Reports::ColumnDefinition.new(:title => "Student Name",  :width => 25),
      Reports::ColumnDefinition.new(:title => "Teachers",      :width => 50)
    ]
  end

  def get_containers(runnable)
    containers = []
    if runnable.kind_of?(Investigation)
      containers = runnable.activities.student_only
    elsif runnable.kind_of?(Activity)
      containers = runnable.sections.student_only
    elsif runnable.kind_of?(Section)
      containers = runnable.pages.student_only
    elsif runnable.kind_of?(Page)
      containers = [runnable]
    end
    return containers
  end
end
