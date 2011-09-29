namespace :app do
  namespace :import do
    desc "import SIS student"
    task :sis_import => :environment do
      SisImporter::BatchJob.new({:verbose => true, :log_level => Logger::ERROR}).run_scheduled_job
    end
  end
end


