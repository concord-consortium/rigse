require 'rake'
require 'csv'

namespace :app do
  namespace :convert do

    desc 'Fix user fields which are not compliant with ActiveRecord validation checks.'
    task :fix_invalid_user_fields => :environment do
        regex = /(?=\A[^[:cntrl:]\\<>\/&]*\z)(.*[\p{L}\d].*)/u
        count = 0
        puts
        puts "ID,Login,First name,Last name,Email"
        User.find_each do |u|
            if !(u.first_name =~ regex && u.last_name =~ regex)
                line = CSV.generate do |csv|
                    csv << [ u.id, u.login, u.first_name, u.last_name, u.email ]
                end
                puts line
                if(u.first_name !~ regex)
                    u.update(first_name: "unknown")
                end
                if(u.last_name !~ regex)
                    u.update(last_name: "unknown")
                end
                count+=1
            end
        end
        puts
        puts "Updated #{count} users."
        puts
    end

    desc "Convert Existing Clazzes so that multiple Teachers can own a clazz. (many to many change)"
    task :convert_clazzes_to_multi_teacher => :environment do
      MultiteacherClazzes.make_all_multi_teacher
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

    # seb: 20100513
    desc "Populate the new leaid, state, and zipcode portal district and school attributes with data from the NCES tables"
    task :populate_new_district_and_school_attributes_with_data_from_nces_tables => :environment do
      puts "\nUpdating #{Portal::District.count} Portal::District models with state, leaid, and zipcode data from the Portal::Nces06District models"
      Portal::District.real.find_in_batches(:batch_size => 500) do |portal_districts|
        portal_districts.each do |portal_district|
          nces_district = Portal::Nces06District.where(:id => portal_district.nces_district_id).select("id, LEAID, LZIP, LSTATE").first
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
          nces_school = Portal::Nces06School.where(:id => portal_school.nces_school_id).select("id, NCESSCH, MZIP, MSTATE").first
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
      suspect_activities = Activity.where("position is null and investigation_id is not null")
      good_activities =  Activity.where("position is not null and investigation_id is not null")
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
    desc "makes sure all Report::Learner attributes are not nil"
    task :remove_report_learner_nils => :environment do
      Report::Learner.find_each(:batch_size => 100) do |rl|
        # we just need to trigger the save hooks
        rl.save
      end
    end

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
          act.update!(:position => position)
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

    desc "move all offerings to default class"
    task :move_offerings_to_default_class => :environment do
      clazz = Portal::Clazz.default_class
      Portal::Offering.all.each do |offering|
        next if offering.clazz_id == clazz.id
        runnable_id = offering.runnable_id
        runnable_type = offering.runnable_type
        found   = Portal::Offering
                      .where(runnable_id: runnable_id,
                             runnable_type: runnable_type)
                      .detect { |o| o.clazz_id == clazz.id }
        unless found
          found = Portal::Offering.create(:runnable_id => runnable_id, :runnable_type => runnable_type, :clazz => clazz, :default_offering => true)
        end
        offering.learners.each do |learner|
          learner.offering = found
          learner.save!
        end
      end
      # We don't need to delete offerings, they are
      # switched out dynamically in the controller
      # Portal::Offering.all.each do |offering|
      #   next if offering.clazz_id == clazz.id
      #   offering.delete
      # end
    end
  end
end

