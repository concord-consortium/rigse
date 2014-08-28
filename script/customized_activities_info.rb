#!/usr/bin/env ruby
STDOUT.sync = true

require File.expand_path(File.join(File.dirname(__FILE__), '..', 'config', 'environment'))
require 'csv'
USED_THRESHOLD = 5


#@activities = []
#if Activity.respond_to?('find_in_batches')
#  Activity.find_in_batches(:batch_size => 100) do |acts|
#    process_activities(acts)
#    @activities = acts
#  end
#else
#  process_activities(Activity.find(:all))
#end

#def from_portal?(act)
#  if act.respond_to?('original') 
#      orig = act.original
#      if orig.nil? || orig.id == 1
#        return false
#      elsif published?(act)
#        return true
#      end
#    else
#      return false
#  end
#end

def from_portal?(act)
  if act.respond_to?('original') && !act.is_exemplar? && published?(act)
    return true
  else
    return false
  end
end

def type(parent)
  if parent.id == 1
    return "original"
  elsif parent.is_exemplar?
    return "copied-from-exemplar"
  else
    return "copied-from-other"
  end  
end

def published?(act)
  if act.respond_to?('publication_status')
    return act.publication_status == "published"
  #elsif act.respond_to?('public?') #there is no public in the new portal
  #  return act.public?
  else
    raise "unknown activity model! #{act.inspect}"
  end
end

##################################
# CODE FROM SCORE CHANGED ACTIVITY
##################################
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

#def score(activity)
#  left = custom_hash(activity)
#  right = custom_hash(activity.original)
#  comparer = Diff::Comparison::Comparer.new(left, right)
#  score = comparer.score(default_rubric) # TODO Pass in a custom rubric...
#  return score
#end

def score(activity, parent)
  left = custom_hash(activity)
  right = custom_hash(parent)
  comparer = Diff::Comparison::Comparer.new(left, right)
  score = comparer.score(default_rubric) # TODO Pass in a custom rubric...
  return score
end

#def calc_generation(activity)
#  generation = 0 # all activities have one parent: the template it was originally created from. So start counting from 0.
#  while activity.original
#    generation += 1
#    activity = activity.original
#    #@ancestor = activity.original
#  end
#  return generation
#end

#def calc_ancestor(activity)  
#  while activity.original
#    ancestor = activity
#    activity = activity.original
#  end
#  return ancestor
#end

def calc_cleanGeneration(activity)
  generation = 0 # all activities have one parent: the template it was originally created from. So start counting from 0.
  realParent = activity
  temp = activity
  while activity.original
    if published?(activity.original) || (activity.user != activity.original.user)
      generation += 1
      if realParent == temp #assign the real parent, this assignment only occurs once in the while loop
        realParent = activity.original
      end
    end
    ancestor = activity
    activity = activity.original
  end
  if ancestor == activity
    ancestor = activity.original
  end
  return generation, realParent, ancestor
end

def used?(activity)
  return activity.offerings.map {|o| o.learners.select{|l| l.bundle_logger.bundle_contents.size > 0 }.size }.sum >= USED_THRESHOLD
end

def number_users(activity)
  return activity.offerings.map {|o| o.learners.select{|l| l.bundle_logger.bundle_contents.size > 0 }.size }.sum
end

@i = 0
def print_progress
  print "." if @i % 10 == 0 && @i != 0
  print("\n%5d: " % [@i]) if @i % 100 == 0
  @i += 1
end

@cohort_teacher_names = []
Portal::Teacher.tagged_with('itsisu').each {|t| @cohort_teacher_names.push(t.name)}
 
#puts "\nScoring #{Activity.count} activities..."
puts "\nGathering details about customized activities...\n"
CSV.open("customized_activities_info_#{Time.now.strftime('%Y%m%d')}.csv", "wb") do |csv|
  csv << ['ID', 'Activity Title', 'Activity Type', 'Score', 'Author Name', 'Author User ID', 'ITSISU?', 'Parent ID', 'Generation', 'Ancestor ID', 'Real Parent ID', 'Used?', '# of Users', 'Creation date', 'Update date', 'Grade Level', 'Real Parent Grade Level']
  Activity.find_each(:batch_size => 10, :include => [:original, {:sections => { :pages => { :page_elements => :embeddable }}}]) do |a|
    next if a.investigation  # These are pre- and post- tests, generally
    next unless from_portal?(a)
    generation, realParent, ancestor = calc_cleanGeneration(a)
    #ancestor = calc_ancestor(a)
    #realParent = calc_realParent(a)
    csv << [a.id, a.name, type(realParent), score(a, realParent), a.user.name, a.user_id, @cohort_teacher_names.include?(a.user.name), a.original_id, generation, ancestor.id, realParent.id, used?(a), number_users(a), a.created_at, a.updated_at, a.grade_level_list.first, realParent && realParent.grade_level_list.first]
    print_progress
    
  end
  
  puts "\n"
end

  
