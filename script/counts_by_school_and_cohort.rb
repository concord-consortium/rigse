#!/usr/bin/env ruby
#
STDOUT.sync = true

require File.expand_path(File.join(File.dirname(__FILE__), '..', 'config', 'environment'))

puts "\nGathering numbers of active students and teachers grouped by school and cohort."

def process_school_data(all_users, type, active, school_data)
  all_users.each do |cohort, users|
    school_data[cohort] ||= {}
    school_data[cohort][type] ||= {}
    school_data[cohort][type][active] ||= 0

    count = users.flatten.compact.uniq.size
    school_data[cohort][type][active] += count
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
  if school.clazzes.size > 0
    school.clazzes.each do |clazz|
      if clazz.offerings.size > 0 and clazz.students.size > 0
        cohorts = clazz.teachers.map{|t| t.cohorts}.flatten.compact.uniq
        cohorts << "none" if cohorts.size == 0

        cohorts.each do |cohort|
          school_teachers[cohort] ||= []
          school_students[cohort] ||= []
          active_school_teachers[cohort] ||= []
          active_school_students[cohort] ||= []

          school_teachers[cohort] << clazz.teachers
          school_students[cohort] << clazz.students

          active_students = clazz.students.select{|st| st.learners.detect{|l| l.bundle_logger.bundle_contents.size > 0 } }
          active_school_students[cohort] << active_students
          active_school_teachers[cohort] << clazz.teachers if active_students.size > 0
        end
      end
    end

    school_data = {}
    process_school_data(school_teachers, :teachers, :all, school_data)
    process_school_data(school_students, :students, :all, school_data)
    process_school_data(active_school_teachers, :teachers, :active, school_data)
    process_school_data(active_school_students, :students, :active, school_data)

    data[school] = school_data
  end

  count += 1
  print "."
  print "\n#{count}: " if count % 60 == 0
end

File.open("counts-by-school-and-cohort.csv","w") do |file|
  file.write("State,District,School,Cohort,Teachers,Active Teachers,Students,Active Students\n")
  data.each do |school, s_data|
    # s_data is [cohort][type][active]
    dist = school.district
    dist_name = dist ? dist.name : "??"
    state = dist.is_a?(Portal::District) ? (dist.state || "??") : "??"
    out = %!"#{state}","#{dist_name}","#{school.name}",!
    s_data.each do |cohort, c_data|
      file.write(out + %!"#{cohort}",#{c_data[:teachers][:all]},#{c_data[:teachers][:active]},#{c_data[:students][:all]},#{c_data[:students][:active]}\n!)
    end
  end
end
