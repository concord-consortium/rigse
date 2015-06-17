class ImportUsers < Struct.new(:import, :content_path)
  def perform
    content_hash = JSON.parse(File.read(content_path), :symbolize_names => true)
    
    duplicate_users = []
    user_for_lara = []
    total_users_count = content_hash[:users].size

    import.update_attribute(:total_imports, total_users_count)

    content_hash[:users].each_with_index do |user, index|
      new_user = User.find_by_login(user[:login]) || User.find_by_login(user[:email])
      unless new_user
        new_user = User.create({
          :email => user[:email],
          :login => user[:login],
          :last_name => user[:last_name],
          :first_name => user[:first_name],
          :password => "password", #default password
          :password_confirmation => "password",
          :require_password_reset => true
          
        }){|u| u.skip_notifications = true}
        new_user.confirm!
        user[:roles].each do |role|
          new_user.add_role(role)
        end
        if user[:teacher]
          if user[:school]
            if user[:school][:district]
              district_params = {}
              district_params[:name] = user[:school][:district][:name]
              district_params[:leaid] = user[:school][:district][:leaid]
              district = Portal::District.find(:first, :conditions => district_params)
            end
            school_params = {}
            school_params[:name] = user[:school][:name] if user[:school][:name]
            school_params[:state] = user[:school][:state] if user[:school][:state]
            school_params[:ncessch] = user[:school][:ncessch] if user[:school][:ncessch]
            school_params[:district_id] = district.id if district
            school = Portal::School.find(:first, :conditions => school_params)
          end
          portal_teacher = Portal::Teacher.new 
          portal_teacher.user = new_user
          portal_teacher.schools << school if school
          user[:cohorts].each do |cohort|
            portal_teacher.cohort_list.add(cohort)
          end
          portal_teacher.save!
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
    File.open(path, "w") do |f|
      f.write({:duplicate_users => duplicate_users}.to_json)
    end

    import.update_attribute(:duplicate_data, path)
    import.update_attribute(:job_finished_at, Time.current)
    File.delete(content_path) if File.exist?(content_path)

    uri = URI.parse("http://127.0.0.1:3001/import/import_users")
    response = HTTParty.post(uri.to_s, :body => {:portal_users => user_for_lara}.to_json, :headers => {"Content-Type" => 'application/json'})
   
  end

  def error(job, exception)
    import.update_attribute(:progress, -1)
    job.destroy
    File.delete(content_path) if File.exist?(content_path)
  end
end