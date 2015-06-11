class ImportUsers < Struct.new(:import, :content_path)
  def perform
    content_hash = JSON.parse(File.read(content_path), :symbolize_names => true)
    
    duplicate_users = []
    user_for_lara = []
    total_users_count = content_hash[:users].size

    import.update_attribute(:total_imports, total_users_count)

    content_hash[:users].each_with_index do |user, index|      
      puts "user #{index}"
      new_user = nil
      user_exist = User.where(email: user[:email]).size > 0 || User.where(login: user[:login]).size > 0
      unless user_exist
        new_user = User.create!({
          :email => user[:email],
          :login => user[:login],
          :last_name => user[:last_name],
          :first_name => user[:first_name],
          :password => "password", 
          :password_confirmation => "password",
          :require_password_reset => true
        });
      else
        duplicate_users << user 
      end
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

    response = HTTParty.post(uri.to_s,
      :body => {:user => user_for_lara},
      :headers => {"Content-Type" => 'application/json'})

    import.update_attribute(:duplicate_data, path)
    import.update_attribute(:job_finished_at, Time.current)
  end
end