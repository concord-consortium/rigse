def fix_url(content)
  content.gsub("http://","https://")
end

def url_logger
    @@my_logger ||= Logger.new("#{Rails.root}/log/update_external_activity_url.log")
end

namespace :update_external_activity do
  desc "Update External Activity URL"
  task :update_url => :environment do
    url_logger.info("\nUpdating External activity URL at #{Time.now}")
    insecure_content_count = 0
    ExternalActivity.all.each do |activity|      
      if activity[:url] && (activity[:url].include? "http://")
        insecure_content_count += 1
        activity[:url] = fix_url(activity[:url])
        if activity[:launch_url] && (activity[:launch_url].include? "http://")
          activity[:launch_url] = fix_url(activity[:launch_url])
        end
        activity.save!
        url_logger.info("\n  #{activity[:id]}:#{activity[:name]} \t => \t#{activity[:url]}")
      end
    end
    url_logger.info("\n#{insecure_content_count} records updated.")
    p "#{insecure_content_count} records updated."
  end

end

