namespace :lara2 do
  desc "Migrates LARA activity urls to AP"
  task :migrate_lara_urls_to_ap => :environment do

    puts "Enter the AP url along with any query parameters, example: \"https://activity-player.concord.org/?answersSourceKey=foo&portalReport=https://example.com\""
    raw_ap_url = STDIN.gets.chomp()
    begin
      raise "No AP url entered" if raw_ap_url.empty?

      raise "Should be https url" unless raw_ap_url.starts_with?("https://")

      # this throws an exception on invalid urls
      URI.parse(raw_ap_url)

      lara_tool = Tool.find_by_name("LARA")
      raise "No LARA tool found" if lara_tool.nil?

      ap_tool = Tool.find_by_name("ActivityPlayer")
      raise "No ActivityPlayer tool found" if ap_tool.nil?

      puts "Migrating urls..."

      migrate_count = 0
      total_count = 0

      ActiveRecord::Base.transaction do
        ExternalActivity.where(:tool_id => lara_tool.id).find_each(batch_size: 1000) do |ea|
          # make sure this is an activity or sequence from LARA
          activity_uri = URI.parse(ea.url)
          match = /^\/(activities|sequences)\/(\d+)/.match(activity_uri.path)
          if match != nil

            # convert the activity or sequence path to the api path for the same resource
            activity_uri.path = "/api/v1/#{match[1]}/#{match[2]}.json"
            if match[1] == "activities"
              query_param = ["activity", activity_uri.to_s]
            else
              query_param = ["sequence", activity_uri.to_s]
            end

            # need to do this in each loop as we update the query member with the activity url
            ap_uri = URI.parse(raw_ap_url)
            ap_uri.query = URI.encode_www_form(URI.decode_www_form(ap_uri.query || '') << query_param)

            ea.legacy_lara_url = ea.url
            ea.url = ap_uri.to_s
            ea.tool_id = ap_tool.id
            ea.save!

            migrate_count = migrate_count + 1

            print "."
            STDOUT.flush
          end
          total_count = total_count + 1
        end

        puts "Migrated #{migrate_count} out of #{total_count} LARA urls found"
      end

    rescue => e
      puts "ERROR: #{e.to_s}"
    end
  end

  desc "Reset external activity urls to legacy_lara_url values"
  task :reset_external_activity_urls_to_legacy_lara_url => :environment do
    begin
      lara_tool = Tool.find_by_name("LARA")
      raise "No LARA tool found" if lara_tool.nil?

      ap_tool = Tool.find_by_name("ActivityPlayer")
      raise "No ActivityPlayer tool found" if ap_tool.nil?

      puts "Are you sure you want to PERMANENTLY reset the external activity urls to the legacy_lara_url values (where not NULL)? Enter 'YES' to confirm:"
      if STDIN.gets.chomp == "YES"
        puts "Resetting urls"

        reset_count = 0
        total_count = 0
  
        ActiveRecord::Base.transaction do
          ExternalActivity.where(:tool_id => ap_tool.id).where("legacy_lara_url IS NOT NULL").find_each(batch_size: 1000) do |ea|
            # double check
            if !ea.legacy_lara_url.empty?
              ea.url = ea.legacy_lara_url
              ea.legacy_lara_url = nil
              ea.tool_id = lara_tool.id
              ea.save!

              reset_count = reset_count + 1
            end
            total_count = total_count + 1
          end

          puts "Reset #{reset_count} out of #{total_count} AP urls found with legacy LARA urls"
        end
      else 
        raise "Aborting reseting urls"
      end    
    rescue => e
      puts "ERROR: #{e.to_s}"
    end
  end

  desc "migrates external report urls"
  task :migrate_external_report_urls do
    # "Class Dashboard" is the existing LARA class dashboard an should be changed to "Activity Player Dashboard"

    begin
      ap_tool = Tool.find_by_name("ActivityPlayer")
      raise "No ActivityPlayer tool found" if ap_tool.nil?

      ap_report = ExternalReport.find_by_name("Activity Player Report")
      raise "No 'Activity Player Report' external report found" if ap_report.nil?

      lara_dashboard_report = ExternalReport.find_by_name("Class Dashboard")
      raise "No 'Class Dashboard' external report found" if lara_dashboard_report.nil?

      ap_dashboard_report = ExternalReport.find_by_name("Activity Player Dashboard")
      raise "No 'Activity Player Dashboard' external report found" if ap_dashboard_report.nil?

      puts "Are you sure you want to PERMANENTLY migrate the external activity reports for AP activities? Enter 'YES' to confirm:"
      if STDIN.gets.chomp == "YES"
        puts "Migrating reports"

        # first set the default report type for AP activities to be the "Activity Player Report"
        ap_report.default_report_for_source_type = ap_tool.source_type
        ap_report.save!

        # and then make sure no other default report type is set for AP activities
        ExternalReport
          .where('id != ? AND default_report_for_source_type = ?', ap_report.id, ap_tool.source_type)
          .update_all(default_report_for_source_type: nil)        

        migrated_count = 0
        total_count = 0
  
        ActiveRecord::Base.transaction do
          ExternalActivity.includes(:external_reports).where(:tool_id => ap_tool.id).find_each(batch_size: 1000) do |ea|

            migrated = false

            # remove the lara dashboard report
            if ea.external_reports.exists?(lara_dashboard_report.id)
              ea.external_reports.delete(lara_dashboard_report.id)
              migrated = true
            end

            # add the ap dashboard report
            if !ea.external_reports.exists?(ap_dashboard_report.id)
              ea.external_reports << ap_dashboard_report
              migrated = true
            end
            
            if migrated and ea.valid?
              ea.save!
              migrated_count = migrated_count + 1
            end
            
            total_count = total_count + 1
          end

          puts "Migrated external reports in #{migrated_count} out of #{total_count} AP activities found"
        end
      else 
        raise "Aborting migrating reports"
      end    
    rescue => e
      puts "ERROR: #{e.to_s}"
    end
  end
end
