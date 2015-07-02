class GenerateSchoolDistrictJSON < Struct.new(:export_id,:user_id)
  def perform
    export = Export.find(export_id)
    user = User.find(user_id)
    sql = "SELECT portal_schools.name, portal_schools.description, portal_schools.state, portal_schools.zipcode, portal_schools.ncessch, portal_districts.uuid as district_uuid, CONCAT('#{APP_CONFIG[:site_url]}/portal/schools/', portal_schools.id) as school_url 
           FROM portal_districts 
           RIGHT OUTER JOIN portal_schools
           ON portal_schools.district_id = portal_districts.id
           ORDER BY portal_schools.ncessch desc;"
    records_array = ActiveRecord::Base.connection.select_all(sql)
    export_data = {:schools => records_array }

    sql = "SELECT name, description, state, zipcode, leaid, uuid
           FROM portal_districts
           ORDER BY leaid desc;"
    records_array = ActiveRecord::Base.connection.select_all(sql)
    export_data[:districts] = records_array
    name = "portal_schools_#{UUIDTools::UUID.timestamp_create.hexdigest}.json"
    directory = "public/json"
    path = File.join(directory, name)
    dir = File.dirname(path)
    FileUtils.mkdir_p(dir) unless File.directory?(dir)
    File.open(path, "w") do |f|
      f.write(export_data.to_json)
    end
    export.update_attribute(:file_path, path)
    export.update_attribute(:job_finished_at, Time.current)
    export.send_mail(user)
  end
end