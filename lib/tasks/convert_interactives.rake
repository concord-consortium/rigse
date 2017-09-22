require 'rake'

namespace :app do
  namespace :materials do

    desc 'convert interactives to external_activities'
    task :convert_interactives => :environment do

      puts "Creating new external_activities from existing interactives."

      interactives = Interactive.all
      interactives.each do |interactive|
        external_activity = ExternalActivity.create( 
            { 
                :name               => interactive.name,
                :description        => interactive.description,
                :publication_status => interactive.publication_status,
                :url                => interactive.url,
                :thumbnail_url      => interactive.image_url,
                :user_id            => interactive.user_id,
                :credits            => interactive.credits,
                :license_code       => interactive.license_code,

                :material_type      => Interactive.name,
                :is_official        => true
            }
        )
        interactive.external_activity_id = external_activity.id
        interactive.save!
      end
    end

  end
end
