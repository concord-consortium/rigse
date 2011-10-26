namespace :app do
  namespace :report do
    desc "Generate an account report"
    task :account, :filename, :needs => :environment do |t, args|
      args.with_defaults(:filename => 'account.xls')

      filename = args[:filename]
      File.new(filename, 'w') do |file|
        rep = Reports::Account.new({:verbose => true})
        rep.run_report(file)
      end
    end

    desc "Generate a detail report"
    task :detail, :filename, :needs => :environment do |t, args|
      args.with_defaults(:filename => 'detail.xls', :hostname => 'portal.concord.org')
      include ActionController::UrlWriter
      default_url_options[:host] = args[:hostname]

      filename = args[:filename]
      File.new(filename, 'w') do |file|
        rep = Reports::Detail.new({:verbose => true, :blobs_url => dataservice_blobs_url})
        rep.run_report(file)
      end
    end

    desc "Generate an usage report"
    task :usage, :filename, :hostname, :needs => :environment do |t, args|
      args.with_defaults(:filename => 'usage.xls', :hostname => 'portal.concord.org')
      include ActionController::UrlWriter
      default_url_options[:host] = args[:hostname]

      filename = args[:filename]
      File.new(filename, 'w') do |file|
        rep = Reports::Usage.new({:verbose => true, :blobs_url => dataservice_blobs_url})
        rep.run_report(file)
      end
    end

    desc "Generate some usage counts"
    task :counts, :needs => :environment do |t|
      Reports::Counts.new.report
    end
  end
end
