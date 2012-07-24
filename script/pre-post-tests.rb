#!/usr/bin/env ruby

require File.expand_path(File.join(File.dirname(__FILE__), '..', 'config', 'environment'))

puts "\nGathering numbers of pre- and post- tests pairs completed."
puts "Collecting pairs: "

sections = Page.published.map{|p| p.section }.uniq
puts "  #{sections.size} found"
sections = sections.select{|s| s.pages.size == 2}
puts "  #{sections.size} with 2 pages"
sections = sections.select{|s| s.pages[1].offerings.count > 0 && s.pages[0].offerings.count > 0}
puts "  #{sections.size} where both have offerings"

last_year_start = Time.local(2010, 9, 1)
last_year_end = Time.local(2011, 6, 30)
this_year_start = Time.local(2011, 9, 1)
this_year_end = Time.local(2012, 6, 30)

sections = sections.map do |s|
  page1 = s.pages[1].offerings.map {|o|
    o.learners.select{|l|
      l.bundle_logger.bundle_contents.count > 0
    }.map{|l| l.student}
  }.flatten.uniq
  page2 = s.pages[0].offerings.map {|o|
    o.learners.select{|l|
      l.bundle_logger.bundle_contents.count > 0
    }.map{|l| l.student}
  }.flatten.uniq

  y2011a = s.pages[1].offerings.map {|o|
    o.learners.select{|l|
      l.bundle_logger.bundle_contents.count > 0 &&
        l.bundle_logger.bundle_contents.detect{|bc|
          bc.updated_at > last_year_start && bc.updated_at < last_year_end
        }
    }.map{|l| l.student}
  }.flatten.uniq
  y2011b = s.pages[0].offerings.map {|o|
    o.learners.select{|l|
      l.bundle_logger.bundle_contents.count > 0 &&
        l.bundle_logger.bundle_contents.detect{|bc|
          bc.updated_at > last_year_start && bc.updated_at < last_year_end
        }
    }.map{|l| l.student}
  }.flatten.uniq

  y2012a = s.pages[1].offerings.map {|o|
    o.learners.select{|l|
      l.bundle_logger.bundle_contents.count > 0 &&
        l.bundle_logger.bundle_contents.detect{|bc|
          bc.updated_at > this_year_start && bc.updated_at < this_year_end
        }
    }.map{|l| l.student}
  }.flatten.uniq
  y2012b = s.pages[0].offerings.map {|o|
    o.learners.select{|l|
      l.bundle_logger.bundle_contents.count > 0 &&
        l.bundle_logger.bundle_contents.detect{|bc|
          bc.updated_at > this_year_start && bc.updated_at < this_year_end
        }
    }.map{|l| l.student}
  }.flatten.uniq

  {:section => s, :all_students => (page1 & page2).uniq, :last_year => (y2011a & y2011b).uniq, :this_year => (y2012a & y2012b).uniq}
end
sections = sections.select{|s| !(s[:all_students].empty?)}
puts "  #{sections.size} where students have run both"

total = 0
lyear = 0
tyear = 0
sections.each do |pair|
  # find all of the learners
  count = pair[:all_students].size
  lcount = pair[:last_year].size
  tcount = pair[:this_year].size

  puts "#{pair[:section].name}: total: #{count}, 2011: #{lcount}, 2012: #{tcount}"

  total += count
  lyear += lcount
  tyear += tcount
end

puts "Total pairs: #{total}"
puts "Total 2011: #{lyear}"
puts "Total 2012: #{tyear}"

