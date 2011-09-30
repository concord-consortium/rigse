namespace :app do
  namespace :import do
    desc "import SIS student"
    task :sis_import => :environment do
      config = SisImporter::RemoteConfiguration.new({:verbose => true, :log_level => Logger::ERROR})
      SisImporter::BatchJob.new(config).run_scheduled_job
    end
  end
end


