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

end
