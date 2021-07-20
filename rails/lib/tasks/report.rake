namespace :app do
  namespace :report do
    desc "Generate an account report"
    task :account, [:filename] => :environment do |t, args|
      args.with_defaults(:filename => 'account.xls')

      filename = args[:filename]
      rep = Reports::Account.new(verbose: true)
      book = rep.run_report
      book.save filename
    end

    desc "Generate a detail report"
    task :detail, [:filename] => :environment do |t, args|
      args.with_defaults(:filename => 'detail.xls', :hostname => 'portal.concord.org')
      include Rails.application.routes.url_helpers
      default_url_options[:host] = args[:hostname]

      filename = args[:filename]
      rep = Reports::Detail.new(verbose: true,
                                blobs_url: dataservice_blobs_url,
                                url_helpers: Reports::UrlHelpers.new(:protocol => 'https', :host_with_port => 'portal.concord.org')
                                )
      book = rep.run_report
      book.save filename
    end

    desc "Generate an usage report"
    task :usage, [:filename, :hostname] => :environment do |t, args|
      args.with_defaults(:filename => 'usage.xls', :hostname => 'portal.concord.org')
      include Rails.application.routes.url_helpers
      default_url_options[:host] = args[:hostname]

      filename = args[:filename]
      rep = Reports::Usage.new(verbose: true,
                               blobs_url: dataservice_blobs_url,
                               url_helpers: Reports::UrlHelpers.new(:protocol => 'https', :host_with_port => 'portal.concord.org')
                               )
      book = rep.run_report
      book.save filename
    end

    desc "Generate some usage counts"
    task :counts => :environment do |t|
      Reports::Counts.new.report
    end

    desc "Regenerate all of the Report::Learner objects"
    task :update_report_learners => :environment do |t, args|
      puts "#{Portal::Offering.count} offerings to process...\n"
      i = 0
      Portal::Offering.includes(:runnable,
                                :learners => [
                                    :report_learner,
                                    { :student => :user }
                                ],
                                :clazz => [
                                  :teachers,
                                  :course => :school
                                ] ).find_each do |offering|
        print ("\n%5d: " % i) if (i % 50 == 0)
        offering.learners.each do |learner|
          rl = learner.report_learner
          rl.update_fields
        end
        print '.'
        i += 1
      end
      puts " done."
    end

    desc "Pushes all the Portal::Learner objects to the ElasticSearch database"
    task :update_elastic_search_learners => :environment do |t, args|
      learners_count = Portal::Learner.count
      puts "#{learners_count} learners to process...\n"
      i = 0

      offering_includes = [
        :runnable,
        :clazz => [
          :teachers,
          :course => :school
        ]
      ]
      learner_includes = [
        :report_learner_only_id,
        :student => [
          :user,
          :permission_forms
        ]
      ]
      Portal::Offering.includes(offering_includes).find_each(batch_size: 100) do |offering|
        offering.learners.includes(learner_includes).find_each do |learner|
          learner.update_report_model_cache(true)
          i += 1
          puts "#{i} of #{learners_count} learners processed" if (i % 100 == 0)
        end
      end
      puts "Done: #{i} of #{learners_count} learners processed"
    end

    # NP 2019-05-24: Preparing to move to reporting service.
    # Part of: https://www.pivotaltracker.com/story/show/165217423
    # The idea is to update about ~500K learner-runs in LARA to include
    # `class_hash` values, which we need for FireStore authorization Rules
    # LINE FORMAT: CLAZZ_ID, CLASS_HASH, LEARNER_ID, LEARNER_KEY, USER_ID, OFFERING_ID
    desc "export clazz-learner keys to clazz-learners.csv. Import into LARA Runs"
    task :write_class_and_learner_keys => :environment do
      filename = ENV["CLASS_EXPORT_FILENAME"] || "clazz-learners.csv"
      File.open(filename, 'w') do |outfile|
        Portal::Clazz.find_each(batch_size: 20) do |clazz|
          clazz.offerings.each do |offering|
            offering.learners.find_each(batch_size: 50) do |learner|
              begin
                class_hash = clazz.class_hash
                uid = learner.user.id
                learner_key = learner.secure_key
                offering_id = learner.offering_id
                outfile.write "#{clazz.id},#{class_hash},#{learner.id},#{learner_key},#{uid},#{offering_id}\n"
              rescue => e
                Rails.logger.error "Failed to add learner #{e}"
              end
            end
          end
        end
      end
    end
  end
end
