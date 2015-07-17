class Import::ImportExternalActivity < Struct.new(:import,:activity_json,:portal_url,:auth_url,:current_visitor_id)

  def perform
    begin
      Timeout.timeout(60) {
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
            import.update_attribute(:job_finished_at, Time.current)
            import.update_attribute(:progress, 100)
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
            import.update_attribute(:job_finished_at, Time.current)
            import.update_attribute(:progress, -1)  
          end
        else
          import.update_attribute(:job_finished_at, Time.current)
          import.update_attribute(:progress, -1)
        end
      }
    rescue Timeout::Error
      import.update_attribute(:job_finished_at, Time.current)
      import.update_attribute(:progress, -1)
    end
  end

  def max_attempts
    1
  end

  def error(job, exception)
    p exception
    import.update_attribute(:job_finished_at, Time.current)
    import.update_attribute(:progress, -1)
  end
end