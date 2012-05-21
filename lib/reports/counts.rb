class Reports::Counts
  def report
    puts "Teachers: #{teachers.size}"
    puts "  By cohort:"
    c = teacher_counts_by_cohort
    File.open("counts-teachers.csv", "w") {|f| f.write(c); f.flush }
    puts c
    puts "  Active: #{active_teachers.size}"
    puts "    By cohort:"
    c = active_teacher_counts_by_cohort
    File.open("counts-active-teachers.csv", "w") {|f| f.write(c); f.flush }
    puts c
    puts "Students: #{students.size}"
    puts "  By cohort:"
    c = student_counts_by_cohort
    File.open("counts-students.csv", "w") {|f| f.write(c); f.flush }
    puts c
    puts "  Active: #{active_students.size}"
    puts "    By cohort:"
    c = active_student_counts_by_cohort
    File.open("counts-active-students.csv", "w") {|f| f.write(c); f.flush }
    puts c
    puts "Classes : #{clazzes.size}"
    puts "  Active: #{active_clazzes.size}"
  end

  def students
    @students = Portal::Student.all unless @students
    @students
  end

  def active_students
    @active_students = active_learners.collect{|l| l.student}.uniq unless @active_students
    @active_students
  end

  def active_learners
    unless @active_learners
      @active_learners = Portal::Learner.all.select do |learner|
        learner.sessions > 0
      end
    end
    @active_learners
  end

  def teachers
    @teachers = Portal::Teacher.all unless @teachers
    @teachers
  end

  def active_teachers
    unless @active_teachers
      teachers = active_clazzes.collect do |clazz|
        clazz.teachers
      end
      @active_teachers = teachers.flatten.uniq
    end
    @active_teachers
  end

  def cohort_counts(set)
    counts = {}
    set.each do |t|
      cs = t.cohorts
      cs.each do |c|
        counts[c.name] ||= 0
        counts[c.name] += 1
      end
      if cs.size == 0
        counts['none'] ||= 0
        counts['none'] += 1
      end
    end
    return counts
  end

  BY_STATE = lambda {|t| (t.school && t.school.district) ? t.school.district.state : nil }
  BY_DISTRICT = lambda {|t| t.school ? t.school.district : nil}
  BY_SCHOOL = lambda {|t| t.school ? t.school : nil}
  BY_COHORT = lambda {|t|
    cs = t.cohort_list || "none" if t.is_a?(Portal::Teacher)
    if t.is_a?(Portal::Student)
      cs = t.teachers.map{|te| te.cohorts }.flatten.uniq.map{|c| c.name }.join(", ")
    end
    cs
  }

  def teacher_counts_by_cohort
    cohort_counts(teachers)
  end

  def active_teacher_counts_by_cohort
    cohort_counts(active_teachers)
  end

  def student_counts_by_cohort
    cohort_counts(students)
  end

  def active_student_counts_by_cohort
    cohort_counts(active_students)
  end

  def cohort_counts(set)
    t_counts = set.extended_group_by([BY_STATE, BY_DISTRICT, BY_SCHOOL, BY_COHORT])
    total = {}
    state_totals = {}
    district_totals = {}
    out = "State|District|School|Cohort|Count"
    t_counts.each do |state, districts|
      districts.each do |district, schools|
        schools.each do |school, cohorts|
          cohorts.each do |cohort, ts|
            cohort = ["none"] if cohort.empty?
            cohort = cohort.join(", ") if cohort.is_a?(Array)
            out << "#{state || "??"}|#{district ? district.name : "??"}|#{school ? school.name : "??" }|#{cohort}|#{ts.size}\n"
          end
        end
      end
    end
    out
  end

  def clazzes
    @clazzes = Portal::Clazz.all unless @clazzes
    @clazzes
  end

  def active_clazzes
    unless @active_clazzes
      clazzes = active_learners.collect do |learner|
        learner.offering.clazz
      end
      @active_clazzes = clazzes.compact.uniq
    end
    @active_clazzes
  end
end
