namespace :archive_portal do

  desc "displays blob and teacher stats"
  task :get_stats => :environment do
    puts "Total Blobs: #{Dataservice::Blob.where("token != '' and content is not null").count()}"
    puts "Total Teachers: #{Portal::Teacher.count()}"
  end

  desc "extract blob images from database and upload to s3"
  task :extract_and_upload_images => :environment do
    s3_config = load_task_config()['s3']
    AWS.config(access_key_id: s3_config['access_key_id'], secret_access_key: s3_config['secret_access_key'], region: s3_config['region'])
    bucket = AWS.s3.buckets[s3_config['bucket']]

    Dataservice::Blob.where("token != '' and content is not null").where(get_where()).find_in_batches(batch_size: 10) do |batch|
      batch.each do |blob|
        path = "#{s3_config['prefix']}/blobs/#{blob.id}/#{blob.token}.#{blob.file_extension}"
        puts "uploading #{path}"
        obj = bucket.objects[path]
        obj.write(blob.content, :acl => :public_read, :content_type => blob.mimetype)
      end
    end
  end

  desc "generates learner details reports for all teachers"
  task :generate_teacher_reports => :environment do
    s3_config = load_task_config()['s3']

    dir = "/tmp/archive_portal/teacher_reports"
    FileUtils.mkdir_p dir

    blobs_url = "https://#{s3_config['bucket']}.s3.amazonaws.com/#{s3_config['prefix']}/blobs"
    url_helpers = Reports::UrlHelpers.new(:protocol => 'https', :host_with_port => 'localhost')

    Portal::Teacher.where(get_where()).includes(:user).find_in_batches(batch_size: 10) do |batch|
      batch.each do |portal_teacher|
        filename = "#{dir}/user_#{portal_teacher.user_id}__portal_teacher_#{portal_teacher.id}__login_#{portal_teacher.user.login}.xls"
        if File.exist?(filename)
          puts "#{filename} already exists, skipping generation"
        else
          puts "generating #{filename}"
          report_learners = Report::Learner.in_classes(portal_teacher.clazzes.flatten.map {|c| c.id})
          runnables = (report_learners.group('concat(report_learners.runnable_type, "_", report_learners.runnable_id)').map{|learner| learner.runnable} or []).compact
          report = Reports::Detail.new(:runnables => runnables, :report_learners => report_learners, :blobs_url => blobs_url, :url_helpers => url_helpers)
          report.run_report filename
        end
      end
    end
  end

  desc "generates learner details reports for all runnables"
  task :generate_runnable_reports => :environment do
    s3_config = load_task_config()['s3']

    dir = "/tmp/archive_portal/runnable_reports"
    FileUtils.mkdir_p dir

    blobs_url = "https://#{s3_config['bucket']}.s3.amazonaws.com/#{s3_config['prefix']}/blobs"
    url_helpers = Reports::UrlHelpers.new(:protocol => 'https', :host_with_port => 'localhost')

    Report::Learner.group('concat(report_learners.runnable_type, "_", report_learners.runnable_id)').preload(:runnable).map do |learner|
      if learner.runnable
        filename = "#{dir}/#{learner.runnable_type.downcase}_#{learner.runnable_id}__#{learner.runnable.name.parameterize}.xls"
        if File.exist?(filename)
          puts "#{filename} already exists, skipping generation"
        else
          puts "generating #{filename}"
          runnables = [learner.runnable]
          report_learners = Report::Learner.with_runnables(runnables)
          report = Reports::Detail.new(:runnables => runnables, :report_learners => report_learners, :blobs_url => blobs_url, :url_helpers => url_helpers)
          report.run_report filename
        end
      else
        puts "No runnable found for #{learner.runnable_type}_#{learner.runnable_id}"
      end
    end
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
