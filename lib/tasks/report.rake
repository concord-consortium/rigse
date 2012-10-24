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
      puts "#{Portal::Learner.count} learners to process...\n"
      i = 0
      Portal::Learner.find_each do |l|
        print ("\n%5d: " % i) if (i % 250 == 0)
        rl = Report::Learner.for_learner(l)
        if args[:force] || (l.bundle_logger.last_non_empty_bundle_content && l.bundle_logger.last_non_empty_bundle_content.updated_at != rl.last_run)
          rl.update_fields
        end
        print '.' if (i % 5 == 4)
        i += 1
      end
      puts " done."
    end

    desc "Update last_run times for lightweight pages"
    task :update_page_last_run => :environment do |t, args|
      puts "#{Portal::Learner.count} learners to process...\n"
      i = 0
      Portal::Learner.find_each do |l|
        print ("\n%5d: " % i) if (i % 250 == 0)
        if l.offering && l.offering.runnable_type == 'Page'
          rl = l.report_learner
          if rl.last_run.nil?
            report_util = Report::Util.new(l, false, true)
            last_run = report_util.saveables.map{|s| s.updated_at}.sort.last
            if last_run
              rl.last_run = last_run
              rl.save
            end
          end
        end
        print '.' if (i % 5 == 4)
        i += 1
      end
      puts " done."
    end

  end
end
