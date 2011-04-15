namespace :app do
  namespace :import do
    desc "import RINET RIEPS SIS student / class data for RI."
    task :rinet => :environment do
      RinetData.new({:verbose => true, :log_level => Logger::ERROR}).run_scheduled_job
    end
  end
end


