#!/usr/bin/env ruby
#
STDOUT.sync = true

require File.expand_path(File.join(File.dirname(__FILE__), '..', 'config', 'environment'))
require 'csv'

puts "\nGathering details about published exemplars...\n"

as = Activity.published_exemplars(:include => {:sections => {:pages => {:page_elements => {:embeddable => [:component]}}}})

CSV.open("activity_info.csv", "wb") do |csv|
  csv << ["ID", "Title", "Link", "Grade Level", "Unit", "Subject Area", "Probes and Models"]
  as.each do |a|
    unit         = a.unit_list.first          # should only be one
    grade_level  = a.grade_level_list.first   # should only be one
    subject_area = a.subject_area_list.first  # should only be one
    next unless unit && grade_level && subject_area

    row = []

    pm = a.probe_and_model_summary
    pm_list = pm[:models] + pm[:probes]

    csv << ([a.id, a.name, "http://itsi.portal.concord.org/activities/#{a.id}.#{a.lightweight? ? 'run_html' : 'jnlp'}", grade_level, unit, subject_area] + pm_list)
  end
end
