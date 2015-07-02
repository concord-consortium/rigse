class GenerateUserJSON < Struct.new(:export_id,:user_id)
  def perform
    export = Export.find(export_id)
    email_user = User.find(user_id)
    users_json = {}
    users_json[:users] = []
    User.find_each do |user|
      next if user.portal_student || user.state == "pending"
      user_data = user.as_json(:only => [:first_name,:last_name,:login,:email])
      user_data[:teacher] = user.portal_teacher ? true : false
      user_data[:school] = user.school ? user.school.as_json(:only => [:name,:ncessch,:state]) : nil
      if user.school
        user_data[:school][:url] = "#{APP_CONFIG[:site_url]}/portal/schools/#{user.school.id}"
        user_data[:school][:district] = user.school.district.as_json(:only => [:name,:leaid,:state])
      end
      user_data[:user_page_url] = user.user_page_url
      user_data[:roles] = []
      user_data[:cohorts] = []
      if user.roles
        user.roles.each do |role|
          user_data[:roles] << role.title
        end
      end
 
      if user.portal_teacher
        user.portal_teacher.cohorts.each do |coh|
          user_data[:cohorts] << coh.name
        end
      end
      users_json[:users] << user_data
    end

    users_json[:portal_name] = APP_CONFIG[:site_url]

    name = "users_#{UUIDTools::UUID.timestamp_create.hexdigest}.json"
    directory = "public/json"
    path = File.join(directory, name)
    dir = File.dirname(path)
    FileUtils.mkdir_p(dir) unless File.directory?(dir)
    File.open(path, "w") do |f|
      f.write(users_json.to_json)
    end
    export.update_attribute(:file_path, path)
    export.update_attribute(:job_finished_at, Time.current)
    export.send_mail(email_user)
  end
end