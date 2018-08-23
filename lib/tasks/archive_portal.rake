namespace :archive_portal do

  desc "displays blob and teacher stats"
  task :get_stats => :environment do
    puts "Total Blobs: #{Dataservice::Blob.where("token != '' and content is not null").count()}"
    puts "Total Teachers: #{Portal::Teacher.count()}"
  end

  desc "extract blob images from database and upload to s3"
  task :extract_and_upload_images => :environment do
    s3_config = load_task_config()['s3']
    Aws.config.update({
      region: s3_config['region'],
      credentials: Aws::Credentials.new(s3_config['access_key_id'], s3_config['secret_access_key'])
    })
    s3 = Aws::S3::Resource.new
    bucket = s3.bucket(s3_config['images_bucket'])
    Dataservice::Blob.where("token != '' and content is not null").where(get_where()).find_in_batches(batch_size: 10) do |batch|
      batch.each do |blob|
        path = "#{s3_config['images_bucket_prefix']}/blobs/#{blob.id}/#{blob.token}.#{blob.file_extension}"
        puts "uploading #{path}"
        obj = bucket.object(path)
        obj.put(body: blob.content, acl: 'public-read', content_type: blob.mimetype)
      end
    end
  end

  desc "generates learner details reports for all teachers and uploads them to s3"
  task :generate_teacher_reports => :environment do
    # Disable SQL output
    ActiveRecord::Base.logger.level = 1

    s3_config = load_task_config()['s3']
    Aws.config.update({
      region: s3_config['region'],
      credentials: Aws::Credentials.new(s3_config['access_key_id'], s3_config['secret_access_key'])
    })
    s3 = Aws::S3::Resource.new
    bucket = s3.bucket(s3_config['data_bucket'])

    blobs_url = "https://#{s3_config['images_bucket']}.s3.amazonaws.com/#{s3_config['images_bucket_prefix']}/blobs"
    url_helpers = Reports::UrlHelpers.new(:protocol => 'https', :host_with_port => 'localhost')

    failed_teacher_ids = []

    Portal::Teacher.where(get_where()).includes(:user).find_in_batches(batch_size: 10) do |batch|
      batch.each do |portal_teacher|
        puts "processing teacher: #{portal_teacher.id}, user: #{portal_teacher.user.id}, login: #{portal_teacher.user.login}"
        report_learners = Report::Learner.in_classes(portal_teacher.clazzes.flatten.map {|c| c.id})
        runnables = (report_learners.group('concat(report_learners.runnable_type, "_", report_learners.runnable_id)').map{|learner| learner.runnable} or []).compact
        if report_learners.count == 0 || runnables.count == 0
          puts "done, no learners or runnables"
          next
        end
        report = Reports::Detail.new(:runnables => runnables, :report_learners => report_learners, :blobs_url => blobs_url, :url_helpers => url_helpers)
        begin
          spreadsheet = report.run_report
          path = "#{s3_config['data_bucket_prefix']}/teacher_reports/user_#{portal_teacher.user_id}__portal_teacher_#{portal_teacher.id}__login_#{portal_teacher.user.login}.#{spreadsheet.file_extension}"
          obj = bucket.object(path)
          obj.put(body: spreadsheet.to_data_string)
          puts "done - #{path}"
        rescue StandardError => e
          puts "failed"
          puts e.message
          puts e.backtrace.join("\n")
          failed_teacher_ids << portal_teacher.id
        end
        STDOUT.flush
      end
    end
    puts "failed teachers: #{failed_teacher_ids}"
  end

  desc "generates learner details reports for all runnables and uploads them to s3"
  task :generate_runnable_reports => :environment do
    # Disable SQL output
    ActiveRecord::Base.logger.level = 1

    s3_config = load_task_config()['s3']
    Aws.config.update({
      region: s3_config['region'],
      credentials: Aws::Credentials.new(s3_config['access_key_id'], s3_config['secret_access_key'])
    })
    s3 = Aws::S3::Resource.new
    bucket = s3.bucket(s3_config['data_bucket'])

    blobs_url = "https://#{s3_config['bucket']}.s3.amazonaws.com/#{s3_config['prefix']}/blobs"
    url_helpers = Reports::UrlHelpers.new(:protocol => 'https', :host_with_port => 'localhost')

    failed_runnables = []

    [ExternalActivity, Investigation, Activity].each do |type|
      type.find_in_batches(batch_size: 10) do |batch|
        batch.each do |runnable|
          puts "processing runnable #{runnable.class.name}_#{runnable.id}"
          runnables = [runnable]
          report_learners = Report::Learner.where(runnable_type: runnable.class.name, runnable_id: runnable.id)
          if report_learners.count == 0
            puts "no learners, skipping report generation"
            next
          end
          report = Reports::Detail.new(:runnables => runnables, :report_learners => report_learners, :blobs_url => blobs_url, :url_helpers => url_helpers)
          begin
            spreadsheet = report.run_report
            path = "#{s3_config['data_bucket_prefix']}/runnable_reports/#{runnable.class.name.downcase}_#{runnable.id}__#{runnable.name.parameterize}.#{spreadsheet.file_extension}"
            obj = bucket.object(path)
            obj.put(body: spreadsheet.to_data_string)
            puts "done - #{path}"
          rescue StandardError => e
            puts "failed"
            puts e.message
            puts e.backtrace.join("\n")
            failed_runnables << "#{runnable_type}_#{runnable_id}"
          end
          STDOUT.flush
        end
      end
    end
    puts "failed runnables: #{failed_runnables}"
  end

  def load_task_config
    config_path = Rails.root.join('config/archive_portal.yml')
    abort "#{config_path} not found!" unless File.exist?(config_path)
    YAML.load_file(config_path)
  end

  def get_where
    # allow additional where clause so that we can resume later without reprocessing existing images or reports
    # NOTE: if you use operators, like id >= 400, the entire argument needs to be in a string, like 'id >= 400', so the shell doesn't parse it
    where = ARGV.drop(1).join(' ')
    where = '1 = 1' unless where.length > 0
  end

end
