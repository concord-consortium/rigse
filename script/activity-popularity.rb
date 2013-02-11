acts = Activity.published; nil

sorted  = acts.map do |a|
  os = a.offerings.map do |o|
    last_run = o.learners.map{|l| bc = l.bundle_logger.last_non_empty_bundle_content; bc ? bc.created_at : nil }.compact.sort.last
    {:learners => o.learners.size, :teachers => o.clazz.teachers, :last_run => last_run}
  end
  num_learners = os.map{|o| o[:learners]}.inject(:+) || 0
  num_teachers = os.map{|o| o[:teachers]}.flatten.compact.uniq.size
  last_run = os.map{|o| o[:last_run]}.compact.sort.last
  {:id => a.id, :name => a.name, :learners => num_learners, :teachers => num_teachers, :last_run => last_run }
end; nil

sorted2 = acts.map do |a|
  os = a.offerings.map do |o|
    learners = o.learners.select{|l| l.created_at > 1.year.ago}
    last_run = learners.map{|l| bc = l.bundle_logger.last_non_empty_bundle_content; bc ? bc.created_at : nil }.compact.sort.last
    {:learners => learners.size, :teachers => (last_run ? o.clazz.teachers : []), :last_run => last_run}
  end
  num_learners = os.map{|o| o[:learners]}.inject(:+) || 0
  num_teachers = os.map{|o| o[:teachers]}.flatten.compact.uniq.size
  last_run = os.map{|o| o[:last_run]}.compact.sort.last
  {:id => a.id, :name => a.name, :learners => num_learners, :teachers => num_teachers, :last_run => last_run }
end; nil

sorted = sorted.sort_by{|b| b[:learners]}; nil
sorted2 = sorted2.sort_by{|b| b[:learners]}; nil

File.open("pop_acts_alltime.csv", "w") {|f| f.write("ID,Name,Teachers,Learners,Last Run\n"); sorted.reverse_each {|a| f.write(%!#{a[:id]},"#{a[:name].gsub(/"/,"'")}",#{a[:teachers]},#{a[:learners]},#{a[:last_run]}\n!) } }; nil
File.open("pop_acts_lastyear.csv","w") {|f| f.write("ID,Name,Teachers,Learners,Last Run\n"); sorted2.reverse_each{|a| f.write(%!#{a[:id]},"#{a[:name].gsub(/"/,"'")}",#{a[:teachers]},#{a[:learners]},#{a[:last_run]}\n!) } }; nil

