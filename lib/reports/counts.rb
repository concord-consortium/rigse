class Reports::Counts
  def report
    puts "Teachers: #{teachers.size}"
    puts "  By cohort:"
    puts teacher_counts_by_cohort
    puts "  Active: #{active_teachers.size}"
    puts "    By cohort:"
    puts active_teacher_counts_by_cohort
    puts "Students: #{students.size}"
    puts "  Active: #{active_students.size}"
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

  def teacher_counts_by_cohort
    cohort_counts(teachers).map{|name, count| "#{"%15s" % name}: #{"%6d" % count}" }.join("\n")
  end

  def active_teacher_counts_by_cohort
    cohort_counts(active_teachers).map{|name, count| "#{"%15s" % name}: #{"%6d" % count}" }.join("\n")
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
