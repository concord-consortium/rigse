# This script will print CSV string with offering assignments count for each provided activity.
# Activities are read from CSV file with following assumption:
#  - activity URL is the first URL in each line
#  - first line of CSV file is header
# It's meant to be run by developer in rails console directly (can be copy-pasted to staging or production console).
# It was used together with LARA scripts generating statistics per each activity (embeddable_stats.rb)
def assignments_count(activities_csv_path)
  ApplicationRecord.logger = nil # disable SQL logging
  line_idx = 0
  File.readlines(activities_csv_path).each do |line|
    urls = URI.extract(line)
    offerings_count = 0
    if line_idx > 0 && urls.count > 0
      activity_url = urls[0] # assume that the first URL is an activity URL
      ExternalActivity.where(url: activity_url).each do |ea|
        offerings_count += ea.offerings_count
      end
    end
    if line_idx === 0
      puts "assignments count"
    else
      puts offerings_count
    end
    line_idx += 1
  end
  nil
end
