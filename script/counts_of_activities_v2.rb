#!/usr/bin/env ruby

STDOUT.sync = true

require File.expand_path(File.join(File.dirname(__FILE__), '..', 'config', 'environment'))

fname = "counts_of_activities.txt"
f = File.open(fname, "w")



puts "\nGathering numbers of activities copied or created from scratch."

def is_exemplar?(act)
  if act.respond_to?('is_exemplar?')
    return act.is_exemplar? && act.publication_status == "published" && act.grade_levels.size > 0 && act.subject_areas.size > 0 && act.units.size > 0
  elsif act.respond_to?('public?')
    return act.public? && act.user_id == 13
  else
    raise "unknown activity model!"
  end
end

def published?(act)
  if act.respond_to?('publication_status')
    return act.publication_status == "published"
  elsif act.respond_to?('public?')
    return act.public?
  else
    raise "unknown activity model!"
  end
end

def used?(a)
  if a.respond_to?('offerings')
    return a.offerings.map {|o| o.learners.select{|l| l.bundle_logger.bundle_contents.size > 0 }.size }.sum > 5
  elsif a.respond_to?('learners')
    return a.learners.select {|l| l.learner_sessions.count > 0 }.size > 5
  end
  return false
end

def itsi_cohort?(a)
  return a.user.portal_teacher.cohort_list.include?('itsisu') rescue false
end

def timestamp(a)
  return a.created_at if a.respond_to?('created_at')
  return a.versions.first.updated_at if a.respond_to?('versions')
  return nil
end

@counts = {}

def record_activity(a, type, published, used, itsisu)
  @counts[type] ||= {:earliest => Time.now, :latest => Time.parse("2000-01-01"), :total => 0, :subs => {}}

  @counts[type][:total] += 1

  sub_key = published ? "published" : "unpublished"
  sub_key += used ? "_used" : "_unused"
  sub_key += itsisu ? "_itsisu" : "_general"

  @counts[type][:subs][sub_key] ||= 0
  @counts[type][:subs][sub_key] += 1

  t = timestamp(a)
  unless t.nil?
    @counts[type][:earliest] = t if t < @counts[type][:earliest]
    @counts[type][:latest]   = t if t > @counts[type][:latest]
  end
end

@c = 0
def process_activities(acts)
  acts.each do |a|
    next if a.investigation
    #next if is_exemplar?(a)
    type = :unknown
    if is_exemplar?(a)
      type = :exemplar
    elsif a.respond_to?('original') || a.respond_to?('parent')
      orig = a.respond_to?('original') ? a.original : a.parent
      if orig.nil? || orig.id == 1
        type = :original
      elsif is_exemplar?(orig)
        type = :exemplar_copy
      else
        type = :other_teacher_copy
      end
    end
    record_activity(a, type, published?(a), used?(a), itsi_cohort?(a))
    print "\n#{@c}: " if @c % 60 == 0
    print "."
    @c += 1
  end
end

if Activity.respond_to?('find_in_batches')
  Activity.find_in_batches(:batch_size => 100) do |acts|
    process_activities(acts)
  end
else
  process_activities(Activity.find(:all))
end

puts "\n"

@portal = 0
@counts.keys.sort_by{|k| k.to_s }.each do |k|  #sort the types alphabetically and then for each type do
  v = @counts[k]
 
  #@counter = @counter + v[:total]
  f.puts "#{k}:           #{v[:total]}"
  v[:subs].keys.sort.each do |sk|
    sv = v[:subs][sk]
    f.puts "  #{sk}:      #{sv}"
    if (k == :exemplar_copy or k == :other_teacher_copy) and (sk == "published_unused_general" or sk == "published_unused_itsisu" or sk == "published_used_general" or sk == "published_used_itsisu")
      @portal += sv
    end 
    
  end
end

f.puts "\nnumber of other activities available online on portal: #{@portal}"
f.puts "\ntotal number of activities: #{@c}"
f.close
