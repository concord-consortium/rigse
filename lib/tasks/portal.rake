namespace :portal do
  namespace :fixups do
    desc "Establish SDS counterparts for all models that need it"
    task :create_sds_counterparts => :environment do
      [User, Portal::Learner, Portal::Offering].each do |klass|
        klass.all.each do |u|
          if (! u.sds_config) || (! u.sds_config.sds_id)
            u.create_sds_counterpart
          end
        end
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
  end
end