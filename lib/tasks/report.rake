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
        rep = Reports::Detail.new({:verbose => true,
                                   :blobs_url => dataservice_blobs_url,
                                   :url_helpers => Reports::UrlHelpers.new(:protocol => 'https', :host_with_port => 'portal.concord.org')
                                   })
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
        rep = Reports::Usage.new({:verbose => true,
                                  :blobs_url => dataservice_blobs_url,
                                  :url_helpers => Reports::UrlHelpers.new(:protocol => 'https', :host_with_port => 'portal.concord.org')
                                  })
        rep.run_report(file)
      end
    end

    desc "Generate an usage report"
    task :assigned_usage_with_activities, [:filename, :hostname] => :environment do |t, args|
      args.with_defaults(:filename => 'assigned_usage.xls', :hostname => 'portal.concord.org')
      include ActionController::UrlWriter
      default_url_options[:host] = args[:hostname]

      filename = args[:filename]
      File.new(filename, 'w') do |file|
        all_runnables = Investigation.published + Investigation.assigned
        all_runnables = all_runnables.uniq.sort_by { |i| i.name.downcase }

        rep = Reports::Usage.new({:runnables => all_runnables,
                                  :report_learners => Report::Learner.all,
                                  :blobs_url => dataservice_blobs_url,
                                  :include_child_usage => true,
                                  :verbose => true,
                                  :url_helpers => Reports::UrlHelpers.new(:protocol => 'https', :host_with_port => 'portal.concord.org')
                                   })
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
        if l.offering
          rl = l.report_learner
          if args[:force] || (l.bundle_logger.last_non_empty_bundle_content && l.bundle_logger.last_non_empty_bundle_content.updated_at != rl.last_run)
            rl.update_fields
          end
        end
        print '.' if (i % 5 == 4)
        i += 1
      end
      puts " done."
    end
  end
end
