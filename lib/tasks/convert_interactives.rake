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

    desc 'migrate interactive tags to external_activities'
    task :migrate_interactive_tags => :environment do

        Interactive.includes(
                :material_properties,
                :grade_levels,
                :subject_areas,
                :sensors ).find_each(
                    :conditions => "external_activity_id IS NOT NULL") do |ia|

            ea = ExternalActivity.find(ia.external_activity_id)

            ea.material_property_list   = ia.material_property_list
            ea.grade_level_list         = ia.grade_level_list
            ea.subject_area_list        = ia.subject_area_list
            ea.sensor_list              = ia.sensor_list

            ea.projects                 = ia.projects
            ea.cohorts                  = ia.cohorts

            ea.save
        end
    end

  end
end
