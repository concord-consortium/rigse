namespace :app do
  namespace :report do
    desc "Generate an account report"
    task :account, [:filename] => :environment do |t, args|
      args.with_defaults(:filename => 'account.xls')

      filename = args[:filename]
      File.new(filename, 'w') do |file|
        rep = Reports::Account.new({:verbose => true})
        rep.run_report(file)
      end
    end

    desc "Generate a detail report"
    task :detail, [:filename] => :environment do |t, args|
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
    task :usage, [:filename, :hostname] => :environment do |t, args|
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
    task :counts => :environment do |t|
      Reports::Counts.new.report
    end

    desc "Regenerate all of the Report::Learner objects"
    task :update_report_learners, [:force] => :environment do |t, args|
      args.with_defaults(:force => false)
      learners = Portal::Learner.all
      puts "#{learners.size} learners to process...\n"
      learners.each_with_index do |l,i|
        print ("\n%5d: " % i) if (i % 250 == 0)
        if l.offering
          rl = Report::Learner.for_learner(l)
          if args[:force] || (l.bundle_logger.last_non_empty_bundle_content && l.bundle_logger.last_non_empty_bundle_content.updated_at != rl.last_run)
            rl.update_fields
          end
        end
        print '.' if (i % 5 == 4)
      end
      puts " done."
    end
  end
end
