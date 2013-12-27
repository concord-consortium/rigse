$stdout.sync = true

bc = 0
total = Activity.count
puts "Activities (#{total}):"
Activity.find_in_batches(:batch_size => 100, :include => {:sections => {:pages => {:page_elements => :embeddable}}}) do |as|
  print "#{'%7d' % (bc*100)}: "
  bc += 1
  start_time = Time.now
  as.each do |a|
    print "."
    next if a.user_id <= 12
    next if a.user_id == 459
    next if a.is_exemplar

    a.destroy
  end
  end_time = Time.now
  elapsed = end_time - start_time
  puts " e: #{elapsed}, eta: #{(total/100.0) * (elapsed / 60) - (bc*elapsed/60.0)} minutes"
end

bc = 0
total = User.count
puts "\n\nUsers (#{total}):"
User.find_in_batches(:batch_size => 100) do |users|
  print "#{'%7d' % (bc*100)}: "
  bc += 1
  start_time = Time.now
  users.each do |u|
    print "."
    next if u.id <= 12
    next if u.id == 459

    u.portal_teacher.destroy if u.portal_teacher
    u.portal_student.destroy if u.portal_student
    u.destroy
  end
  end_time = Time.now
  elapsed = end_time - start_time
  puts " e: #{elapsed}, eta: #{(total/100.0) * (elapsed / 60) - (bc*elapsed/60.0)} minutes"
end

