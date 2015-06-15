class ImportUsers < Struct.new(:import, :content_path)
  def perform
    content_hash = JSON.parse(File.read(content_path), :symbolize_names => true)
    
    duplicate_users = []
    user_for_lara = []
    total_users_count = content_hash[:users].size

    import.update_attribute(:total_imports, total_users_count)

    content_hash[:users].each_with_index do |user, index|      
      puts "user #{index}"
      new_user = User.find_or_create_by_login({
        :email => user[:email],
        :login => user[:login],
        :last_name => user[:last_name],
        :first_name => user[:first_name],
        :password => "password", #default password
        :password_confirmation => "password",
        :require_password_reset => true
      }){|u| u.skip_notifications = true}
      if new_user.new_record?
        user[:roles].each do |role|
          new_user.add_role(role)
        end
        if user[:teacher]
          district = Portal::District.find_by_name_and_leaid(user[:school][:district][:name],user[:school][:district][:leaid]) 
          if district
            school = Portal::School.find(:first, :conditions => {name: user[:school][:name], state: user[:school][:state], ncessch: user[:school][:ncessch], district_id: district.id})
          else
            school = Portal::School.find(:first, :conditions => {name: user[:school][:name], state: user[:school][:state], ncessch: user[:school][:ncessch]})
          end
          portal_teacher = Portal::Teacher.new do |t|
            t.user = new_user
            t.schools << school if school
          end
          user[:cohorts].each do |cohort|
            portal_teacher.cohort_list.add(cohort)
          end
        end
      else
        duplicate_users << user 
      end
      user_for_lara << user[:email]
      import.update_attribute(:progress, (index + 1))
    end

    name = "duplicate_users.json"
    directory = "public/json"
    path = File.join(directory, name)
    dir = File.dirname(path)
    FileUtils.mkdir_p(dir) unless File.directory?(dir)
    File.open(path, "a") do |f|
      f.write({:duplicate_users => duplicate_users}.to_json)
    end

    uri = URI.parse("#{APP_CONFIG[:authoring_site_url]}/import/import_users")
    response = HTTParty.post(uri.to_s, :body => {:portal_users => user_for_lara}.to_json, :headers => {"Content-Type" => 'application/json'})

    import.update_attribute(:duplicate_data, path)
    import.update_attribute(:job_finished_at, Time.current)
    File.delete(content_path) if File.exist?(content_path)
  end

  def error(job, exception)
    import.update_attribute(:progress, -1)
    job.destroy
    File.delete(content_path) if File.exist?(content_path)
  end
end