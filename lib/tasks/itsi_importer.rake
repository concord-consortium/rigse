namespace :app do
  namespace :import do
    
    desc "setup itsi environment"
    task :setup_itsi_environment => [:environment, :create_itsi_activity_template] do 
      # prefix will be "ITSI, unless we are using and itsi theme"
      @prefix = (APP_CONFIG[:theme] && APP_CONFIG[:theme] =~ /itsi/i) ? "" : "ITSI: "
      @itsi_import_user = ItsiImporter.find_or_create_itsi_import_user
      require 'hpricot'
      raise "need an 'itsi' specification in database.yml to run this task" unless ITSI_ASSET_URL
    end

    desc "create ITSI Activity template"
    task :create_itsi_activity_template => :environment do
      @itsi_activity_template = ItsiImporter.find_or_create_itsi_activity_template
    end
    
    desc "remove template attribute from activities"
    task :untemplate_activities => :environment do
      templates = Activity.find_all_by_is_template(true)
      templates.each do |t|
        t.is_template = false
        t.save
      end
    end
    
    desc "delete the current ITSI Activity template and create new template"
    task :force_create_itsi_activity_template => :untemplate_activities do
      ItsiImporter.delete_itsi_activity_template
      Rake::Task["app:import:create_itsi_activity_template"].invoke
    end
    
    desc "delete itsi imports"
    task :erase_itsi_imports => :setup_itsi_environment do
      investigations = @itsi_import_user.investigations
      puts "using prefix: #{@prefix}"
      puts "deleting #{investigations.size} pre-existing itsi imports: (d == one import being destroyed .. )"
      # Investigation.find(:all, :conditions => "name like 'ITSI%'").each {|i| print 'd'; i.destroy }
      investigations.each { |i| print 'd'; i.destroy }
      puts
    end
    
    desc "erase and import ITSI activities from the ITSI DIY"
    task :erase_and_import_itsi_activities => :erase_itsi_imports do
      itsi_user = Itsi::User.find_by_login('itest')
      itsi_probe_activities = Itsi::Activity.find_all_by_user_id_and_collectdata_model_active_and_public(itsi_user, false, true)
      itsi_model_activities = Itsi::Activity.find_all_by_user_id_and_collectdata_model_active_and_public(itsi_user, true, true)
      itsi_activities = itsi_probe_activities + itsi_model_activities
      puts "importing #{itsi_activities.length} ITSI Activities ..."
      itsi_activities.each do |itsi_activity| 
        ItsiImporter.create_investigation_from_itsi_activity(itsi_activity, @itsi_import_user,@prefix)
      end
    end
    
    desc "erase and import ITSI DIY activities as ITSI_SU activities"
    task :erase_and_import_itsi_activities => :erase_itsi_imports do
      itsi_user = Itsi::User.find_by_login('itest')
      itsi_probe_activities = Itsi::Activity.find_all_by_user_id_and_collectdata_model_active_and_public(itsi_user, false, true)
      itsi_model_activities = Itsi::Activity.find_all_by_user_id_and_collectdata_model_active_and_public(itsi_user, true, true)
      itsi_activities = itsi_probe_activities + itsi_model_activities
      puts "importing #{itsi_activities.length} ITSI Activities ..."
      itsi_activities.each do |itsi_activity| 
        ItsiImporter.create_activity_from_itsi_activity(itsi_activity, @itsi_import_user,@prefix)
      end
    end
    
    
    desc "re-import ITSI DIY from the CCPortal as ITSI_SU activities with unit tags"
    task :re_import_ccp_itsi_units_to_itsi_su => [:import_ccp_itsi_units_to_itsi_su] do
    end
    
    desc "import ITSI DIY from the CCPortal as ITSI_SU activities with unit tags"
    task :import_ccp_itsi_units_to_itsi_su => :environment do
      ItsiImporter.import_from_cc_portal
    end

    desc "erase and import ITSI Activities from the ITSI DIY collected as Units from the CCPortal"
    task :erase_and_import_ccp_itsi_units => :erase_itsi_imports do
      raise "need an 'ccportal' specification in database.yml to run this task" unless ActiveRecord::Base.configurations['ccportal']
      ccp_itsi_project = Ccportal::Project.find_by_project_name('ITSI')
      puts "importing #{ccp_itsi_project.units.length} ITSI Units ..."
      ccp_itsi_project.units.each do |ccp_itsi_unit|
        ItsiImporter.create_investigation_from_ccp_itsi_unit(ccp_itsi_unit, @itsi_import_user,@prefix)
      end
    end
    
    desc "make all ITSI activities examplars"
    task :make_itsi_exemplars => :environment do
      itsi_user = User.find_by_login('itest')
      itsi_activities = Activity.find_all_by_user_id(itsi_user)
      itsi_activities.each do |itsi_activity| 
        itsi_activity.is_exemplar = true
        itsi_activity.save
      end
    end
    
  end
end


