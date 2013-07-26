#!/usr/bin/env ruby
#
STDOUT.sync = true

require File.expand_path(File.join(File.dirname(__FILE__), '..', 'config', 'environment'))

puts "\nGathering numbers of active students and teachers grouped by school and cohort."

ACTIVE_CLASS_THRESHOLD = 2 # need at least 2 activities in a class to count as active
ACTIVE_STUDENT_THRESHOLD = 2  # need to have run 2 activities to count as an active student
ACTIVE_TEACHER_THRESHOLD = 1  # need 1 active students to count as an active teacher

TIME_THRESHOLDS = {
  "May 2010 - Apr 2012" => {:start => Time.gm(2010,5,1), :finish => Time.gm(2012,4,30,23,59,59)},
  "May 2012 - Apr 2013" => {:start => Time.gm(2012,5,1), :finish => Time.gm(2013,4,30,23,59,59)}
}

def process_school_data(all_users, type, active, school_data, list_dupes = false)
  all_users.each do |cohort, users|
    school_data[cohort] ||= {}
    school_data[cohort][type] ||= {}
    school_data[cohort][type][active] ||= {}
    school_data[cohort][type][active][:count] ||= 0
    school_data[cohort][type][active][:dupes] ||= ""

    users = users.flatten.compact
    unique_users = users.uniq

    school_data[cohort][type][active][:count] += unique_users.size

    if list_dupes
      user_counts = users.inject(Hash.new(0)) {|h,i| h[i] += 1; h}
      school_data[cohort][type][active][:dupes] = user_counts.map{|user,count| count > 1 ? "#{user.name} (#{user.email}): #{count}" : nil}.compact.join("; ")
    end

  end
end

data = {}
print "\n#{Portal::School.count} schools to process...\n0: "

count = 0
Portal::School.find_each(:batch_size => 100) do |school|
  school_teachers = {}
  active_school_teachers = {}
  school_students = {}
  active_school_students = {}
  years = {}
  TIME_THRESHOLDS.each {|yr,thr| years[yr] = {:teachers => {}, :students => {}} }
  if school.clazzes.size > 0
    school.clazzes.each do |clazz|
      if clazz.offerings.size >= 0 and clazz.students.size > 0
        cohorts = clazz.teachers.map{|t| t.cohorts}.flatten.compact.uniq
        cohorts << "none" if cohorts.size == 0

        active_class = clazz.offerings.size >= ACTIVE_CLASS_THRESHOLD

        cohorts.each do |cohort|
          school_teachers[cohort] ||= []
          school_students[cohort] ||= []
          active_school_teachers[cohort] ||= []
          active_school_students[cohort] ||= []

          school_teachers[cohort] << clazz.teachers
          school_students[cohort] << clazz.students

          active_students = clazz.students.select{|st| st.learners.select{|l| l.bundle_logger.bundle_contents.size > 0 }.size >= ACTIVE_STUDENT_THRESHOLD }
          active_school_students[cohort] << active_students
          active_school_teachers[cohort] << clazz.teachers if active_class and active_students.size >= ACTIVE_TEACHER_THRESHOLD

          years_students = {}
          TIME_THRESHOLDS.each do |yr,thr|
            years[yr][:students][cohort] ||= []
            years[yr][:teachers][cohort] ||= []

            active_students = clazz.students.select{|st| st.learners.select{|l| l.bundle_logger.bundle_contents.select{|bc| bc.created_at >= thr[:start] and bc.created_at <= thr[:finish] }.size > 0 }.size >= ACTIVE_STUDENT_THRESHOLD }
            years[yr][:students][cohort] << active_students
            years[yr][:teachers][cohort] << clazz.teachers if active_class and active_students.size >= ACTIVE_TEACHER_THRESHOLD
          end
        end
      end
    end

    school_data = {}
    process_school_data(school_teachers, :teachers, :all, school_data)
    process_school_data(school_students, :students, :all, school_data)
    process_school_data(active_school_teachers, :teachers, :active, school_data, true)
    process_school_data(active_school_students, :students, :active, school_data)

    TIME_THRESHOLDS.each do |yr,thr|
      process_school_data(years[yr][:teachers], :teachers, yr, school_data, true)
      process_school_data(years[yr][:students], :students, yr, school_data)
    end

    data[school] = school_data
  end

  count += 1
  print "."
  print "\n#{count}: " if count % 60 == 0
end

# aggregate the data by state, too
state_data = {}
data.each do |school, s_data|
  dist = school.district
  state = dist.is_a?(Portal::District) ? (dist.state || "??") : "??"
  state_data[state] ||= {}

  s_data.each do |cohort, c_data|
    state_data[state][cohort] ||= {}
    state_data[state][cohort][:teachers] ||= {}
    state_data[state][cohort][:teachers][:all] ||= 0
    state_data[state][cohort][:teachers][:active] ||= 0
    state_data[state][cohort][:teachers][:active_dupes] ||= ""
    state_data[state][cohort][:students] ||= {}
    state_data[state][cohort][:students][:all] ||= 0
    state_data[state][cohort][:students][:active] ||= 0

    state_data[state][cohort][:teachers][:all]     += c_data[:teachers][:all][:count]
    state_data[state][cohort][:teachers][:active]  += c_data[:teachers][:active][:count]
    (state_data[state][cohort][:teachers][:active_dupes]  += c_data[:teachers][:active][:dupes] + ";") if c_data[:teachers][:active][:dupes] != ""
    state_data[state][cohort][:students][:all]     += c_data[:students][:all][:count]
    state_data[state][cohort][:students][:active]  += c_data[:students][:active][:count]

    TIME_THRESHOLDS.each do |yr,thr|
      dupes_sym = (yr.to_s + "_dupes").to_sym
      state_data[state][cohort][:students][yr] ||= 0
      state_data[state][cohort][:teachers][yr] ||= 0
      state_data[state][cohort][:teachers][dupes_sym] ||= ""

      state_data[state][cohort][:teachers][yr]  += c_data[:teachers][yr][:count]
      (state_data[state][cohort][:teachers][dupes_sym]  += c_data[:teachers][yr][:dupes] + ";") if c_data[:teachers][yr][:dupes] != ""

      state_data[state][cohort][:students][yr]  += c_data[:students][yr][:count]
    end
  end
end

File.open("counts-by-school-and-cohort.csv","w") do |file|
  file.write("State,District,School,Cohort,Teachers,Active Teachers,#{TIME_THRESHOLDS.keys.map{|y| "#{y.to_s} Teachers"}.join(",")},Students,Active Students,#{TIME_THRESHOLDS.keys.map{|y| "#{y.to_s} Students"}.join(",")},Notable Teachers,#{TIME_THRESHOLDS.keys.map{|y| "Notable #{y.to_s} Teachers"}.join(",")}\n")
  data.each do |school, s_data|
    # s_data is [cohort][type][active]
    dist = school.district
    dist_name = dist ? dist.name : "??"
    state = dist.is_a?(Portal::District) ? (dist.state || "??") : "??"
    out = %!"#{state}","#{dist_name}","#{school.name}",!
    s_data.each do |cohort, c_data|
      time_teacher_counts = time_student_counts = time_teacher_dupes = ""
      TIME_THRESHOLDS.each do |yr,thr|
        time_teacher_counts += %!#{c_data[:teachers][yr][:count]},!
        time_student_counts += %!#{c_data[:students][yr][:count]},!
        time_teacher_dupes += %!"#{c_data[:teachers][yr][:dupes]}",!
      end
      file.write(out + %!"#{cohort}",#{c_data[:teachers][:all][:count]},#{c_data[:teachers][:active][:count]},#{time_teacher_counts}!)
      file.write(%!#{c_data[:students][:all][:count]},#{c_data[:students][:active][:count]},#{time_student_counts}!)
      file.write(%!"#{c_data[:teachers][:active][:dupes]}",#{time_teacher_dupes}\n!)
    end
  end
end

File.open("counts-by-state-and-cohort.csv","w") do |file|
  file.write("State,Cohort,Teachers,Active Teachers,#{TIME_THRESHOLDS.keys.map{|y| "#{y.to_s} Teachers"}.join(",")},Students,Active Students,#{TIME_THRESHOLDS.keys.map{|y| "#{y.to_s} Students"}.join(",")},Notable Teachers,#{TIME_THRESHOLDS.keys.map{|y| "Notable #{y.to_s} Teachers"}.join(",")}\n")
  state_data.each do |state, s_data|
    # s_data is [cohort][type][active]
    s_data.each do |cohort, c_data|
      time_teacher_counts = time_student_counts = time_teacher_dupes = ""
      TIME_THRESHOLDS.each do |yr,thr|
        dupes_sym = (yr.to_s + "_dupes").to_sym
        time_teacher_counts += %!#{c_data[:teachers][yr]},!
        time_student_counts += %!#{c_data[:students][yr]},!
        time_teacher_dupes += %!"#{c_data[:teachers][dupes_sym]}",!
      end
      file.write(%!"#{state}","#{cohort}",#{c_data[:teachers][:all]},#{c_data[:teachers][:active]},#{time_teacher_counts}!)
      file.write(%!#{c_data[:students][:all]},#{c_data[:students][:active]},#{time_student_counts}!)
      file.write(%!"#{c_data[:teachers][:active_dupes]}",#{time_teacher_dupes}\n!)
    end
  end
end
