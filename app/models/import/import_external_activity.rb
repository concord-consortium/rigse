class Import::ImportExternalActivity < Struct.new(:import,:data_json,:portal_url,:auth_url,:current_visitor_id)

  def perform
    if import.import_type == Import::Import::IMPORT_TYPE_ACTIVITY
      import_object = import_activity(data_json,import)
    else
      import_status = []
      import.total_imports = data_json.size

      data_json.each do |activity|
        activity[:success] = false
      end

      import.update_attribute(:import_data,data_json)
      data_json.each_with_index do |activity,index|
        import_object = Import::Import.create!()
        import_object.update_attribute(:import_type, Import::Import::IMPORT_TYPE_ACTIVITY)
        import_object.update_attribute(:user_id, current_visitor_id)
        #get json from other portal
        activity_url = activity[:activity_url] + "/export_json.json"
        activity_url = activity_url + "?activity_type=prepost&page_id=#{activity[:page_id]}" if activity[:page_id]
        activity_json = get_json(activity_url)
        import_object = import_activity(activity_json,import_object)
        if import_object.progress == 100
          activity[:success] = true
        end
        import_object.destroy
        import.update_attribute(:progress, index+1)
        #change import status of activity in db
        import.update_attribute(:import_data,data_json)
      end
      import.update_attribute(:job_finished_at,Time.current)
    end
  end

  def max_attempts
    1
  end

  def error(job, exception)
    import.update_attribute(:job_finished_at, Time.current)
    import.update_attribute(:progress, -1)
  end

  protected
  def get_json(activity_url)
    response = HTTParty.get(activity_url)
    if response && response.code == 200
      activity_json = JSON.parse "#{response.body}", :symbolize_names => true
    end
    return activity_json if activity_json
  end

  def import_activity(activity_json,import_object)
    begin
      Timeout.timeout(90) {
        client = Client.find(:first, :conditions => {:site_url => APP_CONFIG[:authoring_site_url]})
        auth_token = 'Bearer %s' % client.app_secret
        response = HTTParty.post(auth_url,
        :body => {
          :portal_url => portal_url,
          :activity => activity_json,
          :domain_uid => current_visitor_id
          }.to_json,
        :headers => {"Content-Type" => 'application/json', "Authorization" => auth_token})

        if response.code == 200 #successful
          activity_data = JSON.parse response.headers['data'], :symbolize_names => true
          if activity_data[:response_code] == 201
            import_object.update_attribute(:job_finished_at, Time.current)
            import_object.update_attribute(:progress, 100)
            import_activity = ExternalActivity.find(activity_data[:external_activity_id])
            Admin::Tag.add_new_admin_tags(import_activity,"cohort", activity_json[:cohorts]) if activity_json[:cohorts]
            Admin::Tag.add_new_admin_tags(import_activity,"grade_level", activity_json[:grade_levels]) if activity_json[:grade_levels]
            Admin::Tag.add_new_admin_tags(import_activity,"subject_area", activity_json[:subject_areas]) if activity_json[:subject_areas]
            import_activity.publication_status = activity_json[:publication_status].nil? ? "published" : activity_json[:publication_status] == "published" ? "published" : "private"
            #give author role to creator of activity
            user = User.find_by_email(activity_json[:user_email])
            if user
              user.add_role("author")
              import_activity.user = user
            end
            import_activity.save!
            Sunspot.index(import_activity)
            Sunspot.commit
          else
            import_object.update_attribute(:job_finished_at, Time.current)
            import_object.update_attribute(:progress, -1)  
          end
        else
          import_object.update_attribute(:job_finished_at, Time.current)
          import_object.update_attribute(:progress, -1)
        end
      }
    rescue Timeout::Error
      import_object.update_attribute(:job_finished_at, Time.current)
      import_object.update_attribute(:progress, -1)
    end
    return import_object
  end
end