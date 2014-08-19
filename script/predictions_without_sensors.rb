#!/usr/bin/env ruby

STDOUT.sync = true

require File.expand_path(File.join(File.dirname(__FILE__), '..', 'config', 'environment'))


def is_enabled(pe)
  return pe.is_enabled? && pe.page.is_enabled? && pe.page.section.is_enabled?
end

activities = {}
PageElement.find(:all, :conditions => {:embeddable_type => 'Embeddable::Diy::Sensor'}).each do |pe|
  next unless pe.embeddable.graph_type == "Prediction"
  next unless is_enabled(pe)
  next unless (pe.page.section.activity.is_exemplar? rescue false)
  sensors = pe.embeddable.prediction_graph_destinations
  sensors.each do |s|
    s.page_elements.each do |spe|
      unless is_enabled(spe)
        activities[pe.page.section.activity.id] ||= []
        activities[pe.page.section.activity.id] << pe.page.section.name
      end
    end
  end
end

activities.keys.sort.each do |id|
  puts "#{id}"
  activities[id].uniq.each do |s|
    puts "  #{s}"
  end
end
