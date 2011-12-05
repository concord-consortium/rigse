require 'rake'

namespace :app do
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

    #######################################################################
    #
    # Assign Vernier go!Link as default vendor_interface for users
    # without a vendor_interface.
    #
    #######################################################################
    desc "Assign Vernier go!Link as default vendor_interface for users without a vendor_interface."
    task :assign_vernier_golink_to_users => :environment do
      interface = Probe::VendorInterface.find_by_short_name('vernier_goio')
      User.find(:all).each do |u|
        unless u.vendor_interface
          u.vendor_interface = interface
          u.save
        end
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

    desc 'Data Collectors with a static graph_type to a static attribute; Embeddable::DataCollectors with a graph_type_id of nil to Sensor'
    task :data_collectors_with_invalid_graph_types => :environment do
      puts <<-HEREDOC

This task will search for all Data Collectors with a graph_type_id == 3 (Static)
which was used to indicate a static graph type, and set the graph_type_id to 1 
(Sensor) and set the new boolean attribute static to true.

In addition it will set the graph_type_id to 1 if the existing graph_type_id is nil.
These Embeddable::DataCollectors appeared to be created by the ITSI importer.

There is no way for this transformation to tell whether the original graph was a 
sensor or prediction graph_type so it sets the type to 1 (Sensor).

      HEREDOC
      old_style_static_graphs = Embeddable::DataCollector.find_all_by_graph_type_id(3)
      puts "converting #{old_style_static_graphs.length} old style static graphs and changing type to Sensor"
      attributes = { :graph_type_id => 1, :static => true }
      old_style_static_graphs.each do |dc| 
        dc.update_attributes(attributes)
        print '.'; STDOUT.flush
      end
      puts
      nil_graph_types = Embeddable::DataCollector.find_all_by_graph_type_id(nil)
      puts "changing type of #{nil_graph_types.length} Embeddable::DataCollectors with nil graph_type_ids to Sensor"
      attributes = { :graph_type_id => 1, :static => false }
      nil_graph_types.each do |dc| 
        dc.update_attributes(attributes)
        print '.'; STDOUT.flush
      end
      puts
    end

    desc 'copy truncated Embeddable::Xhtml from Embeddable::Xhtml#content, Embeddable::OpenResponse and Embeddable::MultipleChoice#prompt into name'
    task :copy_truncated_xhtml_into_name => :environment do
      models = [Embeddable::Xhtml, Embeddable::OpenResponse, Embeddable::MultipleChoice]
      puts "\nprocessing #{models.join(', ')} models to generate new names from soft-truncated xhtml.\n"
      [Embeddable::Xhtml, Embeddable::OpenResponse, Embeddable::MultipleChoice].each do |klass|
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
      Admin::Project.create_or_update_default_project_from_settings_yml
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
    
    desc "Create bundle and console loggers for learners"
    task :create_bundle_and_console_loggers_for_learners => :environment do
      Portal::Learner.find(:all).each do |learner|
        learner.console_logger = Dataservice::ConsoleLogger.create! unless learner.console_logger
        learner.bundle_logger = Dataservice::BundleLogger.create! unless learner.bundle_logger
        learner.save!
      end
    end

    desc "Create bundle and console loggers for learners"
    task :create_bundle_and_console_loggers_for_learners => :environment do
      Portal::Learner.find(:all).each do |learner|
        learner.console_logger = Dataservice::ConsoleLogger.create! unless learner.console_logger
        learner.bundle_logger = Dataservice::BundleLogger.create! unless learner.bundle_logger
        learner.save!
      end
    end

    def find_and_report_on_invalid_bundle_contents(&block)
      count = Dataservice::BundleContent.count
      puts "\nScanning #{count} Dataservice::BundleContent model instances for invalid bodies\n\n"      
      invalid = []
      Dataservice::BundleContent.find_in_batches(:batch_size => 10) do |group|
        invalid << group.find_all { |bc| !bc.valid? }
        print '.'; STDOUT.flush
      end
      invalid.flatten!
      if invalid.empty?
        puts "\n\nAll #{count} were valid.\n\n"
      else
        puts "\n\nFound #{invalid.length} invalid Dataservice::BundleContent models.\n\n"
        invalid.each do |bc|
          learner = bc.bundle_logger.learner
          puts "id: #{bc.id}"
          puts " learner #{learner.id}: #{learner.name}; #{learner.student.user.login}"
          puts " investigation: #{learner.offering.runnable.id}: #{learner.offering.name}"
          puts " date #{bc.created_at}"
          yield(bc) if block
          puts
        end
      end
    end

    desc "Find and report on invalid Dataservice::BundleContent objects"
    task :find_and_report_on_invalid_dataservice_bundle_content_objects => :environment do
      find_and_report_on_invalid_bundle_contents
    end

    desc "Find and delete invalid Dataservice::BundleContent objects"
    task :find_and_delete_invalid_dataservice_bundle_content_objects => :environment do
      find_and_report_on_invalid_bundle_contents do |bc|
        puts
        puts " deleting Dataservice::BundleContent id:#{bc.id}..."
        bc.destroy        
      end
    end

    desc "generate otml, valid_xml, and empty attributes for BundleContent objects"
    task :generate_otml_valid_xml_and_empty_attributes_for_bundle_content_objects => :environment do
      count = Dataservice::BundleContent.count
      puts "\nRe-saving #{count} Dataservice::BundleContent model instances\n\n"      
      Dataservice::BundleContent.find_in_batches(:batch_size => 10) do |group|
        group.each { |bc| !bc.save! }
        print '.'; STDOUT.flush
      end
    end
    
    desc "Convert Existing Clazzes so that multiple Teachers can own a clazz. (many to many change)"
    task :convert_clazzes_to_multi_teacher => :environment do
      MultiteacherClazzes.make_all_multi_teacher
    end

    desc "Fixup inner pages so they have a satic area (run migrations first)"
    task :add_static_page_to_inner_pages => :environment do
      innerPageElements = PageElement.all.select { |pe| pe.embeddable_type == "Embeddable::InnerPage" }
      innerPages = innerPageElements.map { |pe| pe.embeddable }
      innerPages.each do |ip|
        if ip.static_page.nil?
          ip.static_page = Page.new
          ip.static_page.user = ip.user
          ip.save
        end
      end
    end
    
    # Feb 3, 2010
    desc "Extract and process learner responses from existing OTrunk bundles"
    task :extract_learner_responses_from_existing_bundles => :environment do
      bl_count = Dataservice::BundleLogger.count
      bc_count = Dataservice::BundleContent.count
      puts "Extracting learner responses from #{bc_count} existing OTrunk bundles belonging to #{bl_count} learners."
      Dataservice::BundleLogger.find_in_batches(:batch_size => 10) do |bundle_logger|
        bundle_logger.each { |bl| bl.extract_saveables }
        print '.'; STDOUT.flush
      end
      puts
    end

    desc "Erase all learner responses and reset the tables"
    task :erase_all_learner_responses_and_reset_the_tables => :environment do
      puts "Erase all saveable learner responses and reset the tables"
      saveable_models = Dir["app/models/saveable/**/*.rb"].collect { |m| m[/app\/models\/(.+?).rb/, 1] }.collect { |m| m.camelize.constantize }
      saveable_models.each do |model|
        if model.respond_to?(:table_name)
          ActiveRecord::Base.connection.delete("TRUNCATE `#{model.table_name}`")
          puts "deleted: all from #{model}"
        end
      end
      puts
    end

    MULTI_CHOICE = /<object refid="([a-fA-F0-9\-]+)!\/(?:embeddable__)?multiple_choice_(\d+)\/input\/choices\[(\d+)\]"(.*?)>/m
    desc "Fix learner bundle contents so that Multiple Choice answers point using an OTrunk local id instead of a path id."
    task :convert_choice_answers_to_local_ids => :environment do
      include ApplicationHelper
      unchanged = {}
      changed = {}
      problems = {}
      Dataservice::BundleContent.find_in_batches(:batch_size => 10) do |batch|
        print '.'; STDOUT.flush
        batch.each do |bundle_content|
          new_otml = bundle_content.otml.gsub(MULTI_CHOICE) {
            retval = ""
            begin
              m_choice = Embeddable::MultipleChoice.find($2.to_i)
              if m_choice
                choice = m_choice.choices[$3.to_i]
                if choice
                  retval = "<object refid=\"#{$1}!/#{ot_local_id_for(choice)}\"#{$4}>"
                else
                  raise "Couldn't find choice #{$3} in Multiple Choice #{$2}"
                end
              else
                raise "Couldn't find Multiple Choice #{$2}"
              end
            rescue => e
              problems[bundle_content.id] ||= []
              problems[bundle_content.id] << "#{e} (#{$&})"
              retval = $&  
            end
            retval
          }
          if new_otml != bundle_content.otml
            changed[bundle_content.id] = true
            bundle_content.otml = new_otml
            # Now convert the otml into actual bundle content
            bundle_content.body = bundle_content.convert_otml_to_body
            bundle_content.save
          else
            unchanged[bundle_content.id] = true
          end

        end # end batch.each
      end # end find_in_batches
      puts "Finished fixing multiple choice references."
      puts "#{changed.size} bundles changed, #{unchanged.size} were unchanged."
      puts "The following #{problems.size} bundles had problems: "
      problems.entries.sort.each do |entry|
        puts "  BC #{entry[0]} (#{changed[entry[0]] ? "changed" : "unchanged"}):"
        puts Dataservice::BundleContent.find(entry[0], :select => 'bundle_logger_id, created_at').description
        entry[1].each do |prob|
          puts "    #{prob}"
        end
      end
    end # end task
    
    # seb: 20100513
    desc "Populate the new leaid, state, and zipcode portal district and school attributes with data from the NCES tables"
    task :populate_new_district_and_school_attributes_with_data_from_nces_tables => :environment do
      puts "\nUpdating #{Portal::District.count} Portal::District models with state, leaid, and zipcode data from the Portal::Nces06District models"
      Portal::District.real.find_in_batches(:batch_size => 500) do |portal_districts|
        portal_districts.each do |portal_district|
          nces_district = Portal::Nces06District.find(:first, :conditions => { :id => portal_district.nces_district_id }, :select => "id, LEAID, LZIP, LSTATE")
          portal_district.state   = nces_district.LSTATE
          portal_district.leaid   = nces_district.LEAID
          portal_district.zipcode = nces_district.LZIP
          portal_district.save!
        end
        print '.'; STDOUT.flush
      end

      puts "\nUpdating #{Portal::School.count} Portal::School models with state, leaid_schoolnum, and zipcode data from the Portal::Nces06School models"
      Portal::School.real.find_in_batches(:batch_size => 500) do |portal_schools|
        portal_schools.each do |portal_school|
          nces_school = Portal::Nces06School.find(:first, :conditions => { :id => portal_school.nces_school_id }, :select => "id, NCESSCH, MZIP, MSTATE")
          portal_school.state           = nces_school.MSTATE
          portal_school.ncessch         = nces_school.NCESSCH
          portal_school.zipcode         = nces_school.MZIP
          portal_school.save!
        end
        print '.'; STDOUT.flush
      end
      puts
    end
  end

  namespace :report do
    # NSP: 20100826
    desc "report on activities without position attributes"
    task :activity_positon_bug_report, [:file_name] => :environment do |t,args|
      args.with_defaults(:file_name => 'position_bug_activity_report.csv')
      file_name = args.file_name
      suspect_activities = Activity.find(:all, :conditions => "position is null and investigation_id is not null")
      good_activities =  Activity.find(:all, :conditions => "position is not null and investigation_id is not null")
      puts "#{suspect_activities.size} without positions & #{good_activities.size} with good positions" 
      bad_hash = suspect_activities.map do |a|
        {
          :id => a.id,
          :inv_id => a.investigation.id,
          :investigation => a.investigation.name,
          :act_size => a.investigation.activities.size,
          :z => "[ #{a.investigation.activities.map{ |iact| iact.id}.join(",")} ]",
          :published => (a.investigation.published? ? "public" : "draft"),
          :offerings => a.investigation.offerings.size,
          :updated => (a.updated_at.strftime("%F"))
        }
      end
      bad_hash = bad_hash.sort_by {|a| [a[:published], a[:inv_id], a[:id] ]}
      File.open(file_name,'w') do |file|
        bad_hash.each do |a|
          line = %/ "#{a[:investigation]}", "#{a[:published]}", "#{a[:act_size]}", "#{a[:updated]}", "#{a[:id]}", "#{a[:z]}"/
          file.puts(line)
        end
      end
      puts "report results should be in #{file_name}"
    end
  end

  namespace :fixup do
    desc "reset all activity position information"
    task :reset_activity_positions => :environment do
      # We actually want to reset the position attribute on ALL activities
      all_invs = Investigation.all
      puts "fixing up #{all_invs.length} investigations"
      all_invs.sort_by { |inv| inv.id }.each do |inv|
        inv.reload # force the default ordering of activities
        act_order = inv.activities.map{ |a| a.id}.join(",")
        puts "working with #{inv.id} #{inv.name}"
        position = 1
        inv.activities.each do |act|
          if (act.position != position)
            puts "    fix: (#{act.position}) ==> (#{position})"
          end
          act.update_attributes!(:position => position)
          position = position + 1
        end
        inv.reload
        new_order = inv.activities.map{ |a| a.id}.join(",")
        raise "Non-matching activity order" unless (new_order == act_order)
        predicted_position = 1
        inv.activities.each do |act|
          raise "Activity has wrong position: #{act.position} != #{predicted_position}" unless (act.position == predicted_position)
          predicted_position = predicted_position + 1
        end
        puts "  reset position information for #{position - 1} activities in #{inv.name}:"
        puts "     PRE: #{act_order}"
        puts "    POST: #{new_order}"
        puts
      end
    end

    desc "delete orphaned teachers, clazzes, students, and learners"
    task :delete_orphaned_items => :environment do
      Portal::Teacher.all.select  {|t| t.user.nil? }.each    {|t| t.delete }
      Portal::Student.all.select  {|s| s.user.nil? }.each    {|s| s.delete }
      Portal::Clazz.all.select    {|c| c.teacher.nil? }.each {|c| c.delete }
      Portal::Learner.all.select  {|l| l.student.nil?}.each  {|l| l.delete }
      Portal::Offering.all.select {|o| o.clazz.nil?}.each    {|o| o.delete }
      Portal::Offering.all.select {|o| o.runnable.nil?}.each {|o| o.delete }
    end

    desc "move vernier_goio vendor interface users to new JNA driver"
    task :use_jna_for_vernier_goio => :environment do
      Fixups.switch_driver('vernier_goio','JNI','JNA')
    end
    
    desc "remove 'teacher' students (users which both, loose their students"
    task :remove_teachers_test_students => :environment do
      Fixups.remove_teachers_test_students
    end
  end
end

