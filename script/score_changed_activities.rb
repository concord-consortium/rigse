#!/usr/bin/env ruby

STDOUT.sync = true

require File.expand_path(File.join(File.dirname(__FILE__), '..', 'config', 'environment'))

require 'csv'

USED_THRESHOLD = 5

def custom_hash(activity)
  ITSI::Comparison.activity_hash(activity)
end

def calc_generation(activity)
  generation = 0 # all activities have one parent: the template it was originally created from. So start counting from 0.
  tmp = activity
  while activity.original
    generation += 1
    activity = activity.original
  end
  return generation
end

def used?(activity)
  return activity.offerings.map {|o| o.learners.select{|l| l.bundle_logger.bundle_contents.size > 0 }.size }.sum >= USED_THRESHOLD
end

def default_rubric
  return Diff::Comparison::Rubric.new(
    {
      :__default__ => Diff::Comparison::RubricRule.new({
        :added => lambda {|currentScore, severity| return currentScore + 1 }, # 1 point for additions
        :changed => lambda {|currentScore, severity| return currentScore + (severity/25.0).ceil }, # 1 to 4 points for changes
        :removed => lambda {|currentScore, severity| return currentScore } # 0 points for deleting things
      })
    }
  )
end

def score(activity)
  left = custom_hash(activity)
  right = custom_hash(activity.original)
  comparer = Diff::Comparison::Comparer.new(left, right)
  score = comparer.score(default_rubric) # TODO Pass in a custom rubric...
  return score
end

@i = 0
def print_progress
  print "." if @i % 10 == 0 && @i != 0
  print("\n%5d: " % [@i]) if @i % 500 == 0
  @i += 1
end

puts "\nScoring #{Activity.count} activities..."

CSV.open("activity_scores_#{Time.now.strftime('%Y%m%d')}.csv", "wb") do |csv|
  csv << ['ID', 'Parent ID', 'Score', 'Author', 'Activity Title', 'Generation', 'Used?']
  Activity.find_each(:batch_size => 10, :include => [:original, {:sections => { :pages => { :page_elements => :embeddable }}}]) do |a|
    next if a.investigation  # These are pre- and post- tests, generally
    csv << [a.id, a.original_id, score(a), a.user.name, a.name, calc_generation(a), used?(a)]
    print_progress
  end
end
