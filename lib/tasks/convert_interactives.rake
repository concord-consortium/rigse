require 'rake'

namespace :app do
  namespace :materials do

    desc 'convert interactives to external_activities'
    task :convert_interactives => :environment do

      puts "Creating new external_activities from existing interactives."

      interactives = Interactive.all
      interactives.each do |interactive|
        ExternalActivity.create( 
            { 
                :name               => "CONVERTED #{interactive.name}",
                :description        => interactive.description,
                :publication_status => interactive.publication_status,
                :url                => interactive.url,
                :thumbnail_url      => interactive.image_url,
                :user_id            => interactive.user_id,
                :credits            => interactive.credits,
                :license_code       => interactive.license_code,

                # :external_type      => "Activity",
                :external_type      => Interactive.name,
                :is_official        => true
            }
        )
      end

    end

    desc 'delete converted interactives'
    task :delete_converted_interactives => :environment do
        
        puts "Deleting converted interactives."

        external_activites = ExternalActivity.all
        external_activites.each do |external_activity|
            if external_activity.name.nil?
                puts "WARN found external_activity with nil name #{external_activity.inspect}"
                next
            end
            if external_activity.name.start_with?("CONVERTED")
                external_activity.destroy
            end
        end
    end

  end
end
