class ImportSchoolsAndDistricts < Struct.new(:import, :content_path)
  def perform
    content_hash = JSON.parse(File.read(content_path), :symbolize_names => true)
    
    non_nces_districts = {}
    total_districts_count = content_hash[:districts].size
    total_schools_count = content_hash[:schools].size
    total_imports_count = total_schools_count + total_districts_count
    district_index = 0

    import.update_attribute(:total_imports, total_imports_count)

    content_hash[:districts].each_with_index do |district, index|
      nces_district = nil
      if district[:leaid]
        nces_district = Portal::Nces06District.find(:first, :conditions => ["LEAID = ?", "#{district[:leaid]}"]);
      end
      if nces_district
        new_district = Portal::District.find_or_create_by_nces_district(nces_district)
      else
        district_name = district[:name].titlecase.strip
        new_district = Portal::District.find_by_name(district_name)
        unless new_district
          new_district = Portal::District.create!({
            :name             => district_name,
            :description      => district[:description],
            :state            => district[:state],
            :zipcode          => district[:zipcode],
            :leaid            => district[:leaid]
          });
          non_nces_districts[district[:uuid]] = new_district.id
        end
      end
      import.update_attribute(:progress, (index + 1))
      district_index = index + 1
    end
    content_hash[:schools].each_with_index do |school, index|
      nces_school= nil
      if school[:ncessch]
        nces_school = Portal::Nces06School.find(:first, :conditions => ["NCESSCH = ?", "#{school[:ncessch]}"])
      end
      if nces_school  
        new_school = Portal::School.find_or_create_by_nces_school(nces_school)
      else
        school_name = school[:name].titlecase.strip
        new_school = Portal::School.find_by_name(school_name)
        unless new_school
          new_school = Portal::School.create({
            :name            => school_name,
            :description     => school[:description],
            :state           => school[:state],
            :zipcode         => school[:zipcode],
            :ncessch         => school[:ncessch],
            :district        => non_nces_districts[school[:uuid]] ? Portal::District.find(non_nces_districts[school[:uuid]]) : nil
          })
        end
      end
      import.update_attribute(:progress, (index + district_index + 1))
    end
    import.update_attribute(:job_finished_at, Time.current)
    File.delete(content_path) if File.exist?(content_path)
  end

  def error(job, exception)
    import.update_attribute(:progress, -1)
    job.destroy
    File.delete(content_path) if File.exist?(content_path)
  end

end