class Import::ImportSchoolsAndDistricts < Struct.new(:import_id)
  def perform
    import = Import::Import.find(import_id)
    content_hash = JSON.parse(import.upload_data, :symbolize_names => true)
    total_districts_count = content_hash[:districts].size
    total_schools_count = content_hash[:schools].size
    total_imports_count = total_schools_count + total_districts_count
    us_country = Portal::Country.find(:first, :conditions =>{:two_letter => "US"})
    district_index = 0
    batch_size = 500
    total_batches = (total_districts_count/batch_size.to_f).ceil
    start_index = 0
    end_index = batch_size - 1

    import.update_attribute(:total_imports, total_imports_count)
    
    0.upto(total_batches-1){|batch_index|
      start_index = batch_index * batch_size
      end_index = (batch_index == total_batches - 1)? (total_districts_count - 1) : (start_index + batch_size - 1)
      ActiveRecord::Base.transaction do
        start_index.upto(end_index){|index|
          district = content_hash[:districts][index]
          nces_district = nil
          if district[:leaid]
            nces_district = Portal::Nces06District.find(:first, :conditions => {:LEAID => district[:leaid]})
          end
          if nces_district
            new_district = Portal::District.find_or_create_by_nces_district(nces_district)
          else
            district_name = district[:name].titlecase.strip
            district_params = {}
            district_params[:name] = district_name
            district_params[:state] = district[:state] if district[:state] 
            district_params[:leaid] = district[:leaid] if district[:leaid]
            existing_district = Portal::District.find(:first, :conditions => district_params)
            new_district = existing_district || Portal::District.create(district_params)
            new_district.description = district[:description]
            new_district.zipcode = district[:zipcode]
            new_district.save!
          end
          new_map = Import::SchoolDistrictMapping.find(:first, :conditions => {:district_id => new_district.id, :import_district_uuid => district[:uuid]})
          new_map = new_map || Import::SchoolDistrictMapping.create({:district_id => new_district.id, :import_district_uuid => district[:uuid]})
          import.update_attribute(:progress, (index + 1))
          district_index = index + 1
        }
      end
    }

    total_batches = (total_schools_count/batch_size.to_f).ceil
    
    0.upto(total_batches-1){|batch_index|
      start_index = batch_index * batch_size
      end_index = (batch_index == total_batches - 1)? (total_schools_count - 1) : (start_index + batch_size - 1)
      ActiveRecord::Base.transaction do
        start_index.upto(end_index){|index|
          school = content_hash[:schools][index]
          nces_school= nil
          if school[:ncessch]
            nces_school = Portal::Nces06School.find(:first, :conditions => {:NCESSCH => school[:ncessch]})
          end
          if nces_school  
            new_school = Portal::School.find_or_create_by_nces_school(nces_school)
          else
            school_name = school[:name].titlecase.strip
            school_district = Import::SchoolDistrictMapping.find(:first, :conditions => {:import_district_uuid => school[:district_uuid]})
            school_params = {}
            school_params[:name] = school_name
            school_params[:state] = school[:state] if school[:state]
            school_params[:district_id] = school_district.district_id if school_district
            school_params[:ncessch] = school[:ncessch] if school[:ncessch]
            existing_school = Portal::School.find(:first ,:conditions => school_params)        
            new_school = existing_school || Portal::School.create(school_params)
            new_school.description = school[:description]
            new_school.zipcode = school[:zipcode]
            new_school.country = us_country unless school[:state] == "XX" || school[:state].nil?
            new_school.save!
          end
          new_map = Import::UserSchoolMapping.find(:first, :conditions => {:school_id => new_school.id, :import_school_url => school[:school_url]})
          new_map = new_map || Import::UserSchoolMapping.create({:school_id => new_school.id, :import_school_url => school[:school_url]})
          import.update_attribute(:progress, (index + district_index + 1))
        }
      end
    }
    Import::SchoolDistrictMapping.delete_all
    import.update_attribute(:job_finished_at, Time.current)
  end

  def error(job, exception)
    p exception
    job.destroy
    import = Import::Import.find(import_id)
    import.update_attribute(:progress, -1)
  end

end