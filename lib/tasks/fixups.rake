require 'rake'

namespace :rigse do
  namespace :convert do

    desc 'Add the author role to all users who have authored an Investigation'
    task :add_author_role_to_authors => :environment do
      User.find(:all).each do |user|
        if user.has_investigations?
          print '.'
          STDOUT.flush
          user.add_role('author')
        end
      end
      puts
    end

    desc 'Remove the author role from users who have not authored an Investigation'
    task :remove_author_role_from_non_authors => :environment do
      User.find(:all).each do |user|
        unless user.has_investigations?
          print '.'
          STDOUT.flush
          user.remove_role('author')
        end
      end
      puts
    end

    desc 'transfer any Investigations owned by the anonymous user to the site admin user'
    task :transfer_investigations_owned_by_anonymous => :environment do
      admin_user = User.find_by_login(APP_CONFIG[:admin_login])
      anonymous_investigations = User.find_by_login('anonymous').investigations
      if anonymous_investigations.length > 0
        puts "#{anonymous_investigations.length} Investigations owned by the anonymous user"
        puts "resetting ownership to the site admin user: #{admin_user.name}"
        anonymous_investigations.each do |inv|
          inv.deep_set_user(admin_user)
          print '.'
          STDOUT.flush
        end
      else
        puts 'no Investigations owned by the anonymous user'
      end
    end

    desc 'ensure investigations have publication_status'
    task :pub_status => :environment do
      Investigation.find(:all).each do |i|
        if i.publication_status.nil?
          i.update_attribute(:publication_status,'draft')
        end
      end
    end

    desc 'Data Collectors with a static graph_type to a static attribute; DataCollectors with a graph_type_id of nil to Sensor'
    task :data_collectors_with_invalid_graph_types => :environment do
      puts <<HEREDOC

This task will search for all Data Collectors with a graph_type_id == 3 (Static)
which was used to indicate a static graph type, and set the graph_type_id to 1 
(Sensor) and set the new boolean attribute static to true.

In addition it will set the graph_type_id to 1 if the existing graph_type_id is nil.
These DataCollectors appeared to be created by the ITSI importer.

There is no way for this transformation to tell whether the original graph was a 
sensor or prediction graph_type so it sets the type to 1 (Sensor).

HEREDOC
      old_style_static_graphs = DataCollector.find_all_by_graph_type_id(3)
      puts "converting #{old_style_static_graphs.length} old style static graphs and changing type to Sensor"
      attributes = { :graph_type_id => 1, :static => true }
      old_style_static_graphs.each do |dc| 
        dc.update_attributes(attributes)
        print '.'; STDOUT.flush
      end
      puts
      nil_graph_types = DataCollector.find_all_by_graph_type_id(nil)
      puts "changing type of #{nil_graph_types.length} DataCollectors with nil graph_type_ids to Sensor"
      attributes = { :graph_type_id => 1, :static => false }
      nil_graph_types.each do |dc| 
        dc.update_attributes(attributes)
        print '.'; STDOUT.flush
      end
      puts
    end

    desc 'copy truncated Xhtml from Xhtml#content, OpenResponse and MultipleChoice#prompt into name'
    task :copy_truncated_xhtml_into_name => :environment do
      models = [Xhtml, OpenResponse, MultipleChoice]
      puts "\nprocessing #{models.join(', ')} models to generate new names from soft-truncated xhtml.\n"
      [Xhtml, OpenResponse, MultipleChoice].each do |klass|
        puts "\nprocessing #{klass.count} #{klass} model instances, extracting truncated text from xhtml and generating new name attribute\n"
        klass.find_in_batches(:batch_size => 100) do |group|
          group.each { |x| x.save! }
          print '.'; STDOUT.flush
        end
      end
      puts
    end
    
    desc 'create default Project from config/settings.yml'
    task :create_default_project_from_config_settings_yml => :environment do
      Admin::Project.create_or_update__default_project_from_settings_yml
    end

    desc 'generate date_str attributes from version_str for MavenJnlp::VersionedJnlpUrls'
    task :generate_date_str_for_versioned_jnlp_urls => :environment do
      puts "\nprocessing #{MavenJnlp::VersionedJnlpUrl.count} MavenJnlp::VersionedJnlpUrl model instances, generating date_str from version_str\n"      
      MavenJnlp::VersionedJnlpUrl.find_in_batches do |group|
        group.each { |j| j.save! }
        print '.'; STDOUT.flush
      end
      puts
    end
    
  end
end

