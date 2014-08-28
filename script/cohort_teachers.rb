#!/usr/bin/env ruby

STDOUT.sync = true

require File.expand_path(File.join(File.dirname(__FILE__), '..', 'config', 'environment'))

require 'csv'

puts "\nGathering info on cohort teachers..."

CSV.open("cohort_teachers_#{Time.now.strftime('%Y%m%d')}.csv", "wb") do |csv|
  csv << ['User ID', 'Name', 'Username', 'Email', 'District', 'School']
  Portal::Teacher.tagged_with('itsisu').each do |t|
    csv << [
      (t.user ? t.user.id : "t: #{t.id}"),
      t.name,
      (t.login rescue "??"),
      (t.email rescue "??"),
      (t.school.district.name rescue "??"),
      (t.school.name rescue "??")
    ]
  end
end

puts "Done."