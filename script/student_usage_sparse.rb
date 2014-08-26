#!/usr/bin/env ruby

STDOUT.sync = true

require File.expand_path(File.join(File.dirname(__FILE__), '..', 'config', 'environment'))

require 'csv'

def display_name(a)
  "#{a.name} [#{a.id}]"
end

def process_student(student)
  result = [
    (student.user.id rescue '???'),
    (student.user.name rescue '???'),
    (student.teachers.map{|t| t.name }.join('; ') rescue '???'),
    (student.clazzes.map{|c| c.name }.join('; ') rescue '???')
  ]

  used_activities = Array.new(ACTIVITIES.size)

  student.learners.each do |learner|
    runnable = learner.offering.runnable
    next if !runnable.is_a?(Activity)
    idx = ACTIVITIES.index(runnable)
    if idx != -1
      used_activities[idx] = 'X'
    else
      $stderr.puts "Found an activity that's not in the activities list! (#{runnable.id} - #{runnable.name})"
    end
  end

  return result + used_activities
end

ACTIVITIES = Activity.find(:all, :conditions => "investigation_id IS NULL").sort_by {|a| display_name(a) }

puts "Processing #{Portal::Learner.count} learners...\n"

CSV.open("student_usage_sparse_#{Time.now.strftime('%Y%m%d')}.csv", "wb") do |csv|
  csv << (['User ID', 'User Name', 'Teacher Names', 'Class Names'] + ACTIVITIES.map{|a| display_name(a) })
  batch_num = 0
  Portal::Student.find_in_batches(:batch_size => 100) do |batch|
    (print "\n%7d: " % (batch_num*100)) if batch_num % 50 == 0

    batch.each do |student|
      csv << process_student(student)
    end

    print '.'
    batch_num += 1
  end
end
puts "\n\ndone."
