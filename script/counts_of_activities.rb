#!/usr/bin/env ruby

STDOUT.sync = true

require File.expand_path(File.join(File.dirname(__FILE__), '..', 'config', 'environment'))

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

@counts = {
  :exemplar_copy => [],
  :exemplar_copy_published => [],
  :other_teacher => [],
  :other_teacher_published => [],
  :original => [],
  :original_published => [],
  :unknown => [],
  :unknown_published => []
}

@c = 0
def process_activities(acts)
  acts.each do |a|
    next if is_exemplar?(a)
    if a.respond_to?('original') || a.respond_to?('parent')
      orig = a.respond_to?('original') ? a.original : a.parent
      if orig.nil?
        @counts[:original].push a
        @counts[:original_published].push(a) if published?(a)
      elsif is_exemplar?(orig)
        @counts[:exemplar_copy].push a
        @counts[:exemplar_copy_published].push(a) if published?(a)
      else
        @counts[:other_teacher].push a
        @counts[:other_teacher_published].push(a) if published?(a)
      end
    else
      @counts[:unknown].push a
      @counts[:unknown_published].push(a) if published?(a)
    end
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

@counts.keys.sort_by{|k| k.to_s }.each do |k|
  v = @counts[k]
  puts "#{k}: #{v.size}"
  if v.size > 0
    if v[0].respond_to?('created_at')
      v = v.sort_by{|a| a.created_at }
    elsif v[0].respond_to?('versions')
      v = v.sort_by{|a| a.versions.first.updated_at }
    else
      v = v.sort_by{|a| a.id }
    end

    earliest = v.first
    latest = v.last
    puts "first: #{earliest.created_at}" if earliest && earliest.respond_to?('created_at')
    puts "last: #{latest.created_at}" if latest && latest.respond_to?('created_at')
    if earliest and earliest.respond_to?('created_at')
      puts "num since Feb 2013: #{v.select{|a| a.created_at > Time.parse('2013-02-01')}.size}"
    end
    puts "first: #{earliest.versions.first.updated_at}" if earliest && earliest.respond_to?('versions')
    puts "last: #{latest.versions.first.updated_at}" if latest && latest.respond_to?('versions')
  end
  puts ""
end
