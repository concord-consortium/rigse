#!/usr/bin/env ruby
STDOUT.sync = true

require File.expand_path(File.join(File.dirname(__FILE__), '..', 'config', 'environment'))

require 'csv'

USED_THRESHOLD = 5

def custom_hash_for_element(element)
  h = nil
  if element.is_enabled?
    h = {}
    embeddable = element.embeddable
    # Depends on the type...
    # These are hand-picked based on what's exposed in the authoring UI
    case embeddable
    when Embeddable::Diy::Section
      h[:content] = embeddable.content
    when Embeddable::OpenResponse
      h[:prompt] = embeddable.prompt
      h[:default_response] = embeddable.default_response
    when Embeddable::DrawingTool
      h[:background_image_url] = embeddable.background_image_url
    when Embeddable::Diy::Sensor
      h[:prototype_id] = embeddable.prototype_id
      h[:multiple_graphable_enabled] = embeddable.multiple_graphable_enabled
    when Embeddable::Diy::EmbeddedModel
      h[:diy_model_id] = embeddable.diy_model_id
    else
      puts "Unknown type: #{embeddable.class.to_s}"
    end
  end
  return h
end

# This makes a ton of assumptions, among them:
# - Each section has a unique name
# - There is only one Embeddable::Diy::Section per page
def custom_hash(activity)
  h = {}
  return h unless activity && activity.is_a?(Activity)
  h[:name] = activity.name
  h[:description] = activity.description
  activity.sections.each do |section|
    h[section.name] = { :enabled => section.is_enabled? }
    next unless section.is_enabled?
    puts "#{section.pages.size} pages" if section.pages.size > 1
    section.pages.each do |page|
      page.page_elements.each_with_index do |element, i|
        embeddable = element.embeddable
        puts "Dupe embeddable class" if h[section.name]["#{embeddable.class}_#{i}"]
        data = custom_hash_for_element(element)
        h[section.name]["#{embeddable.class}_#{i}"] = data if data
      end
    end
  end
  h
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
  csv << ['ID', 'Parent ID', 'Score', 'Author', 'Activity Title', 'Generation', 'Used?', 'User_ID']
  Activity.find_each(:batch_size => 10, :include => [:original, {:sections => { :pages => { :page_elements => :embeddable }}}]) do |a|
    next if a.investigation  # These are pre- and post- tests, generally
    csv << [a.id, a.original_id, score(a), a.user.name, a.name, calc_generation(a), used?(a), a.user_id]
    print_progress
  end
end
