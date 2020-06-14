class NationalDistrictImporter
  def tick(count, interval=25,string='.')
    if count % interval == 0
      print string
      STDOUT.flush
    end
  end

  def _import_schools(school_values)
    portal_school_field_names   = [:name, :uuid, :state, :ncessch, :zipcode, :district_id, :nces_school_id]
    import_options              = {:validate => false }
    Portal::School.import(portal_school_field_names, school_values, import_options)
    nil
  end

  def _import_districts(district_values)
    portal_district_field_names = [:name, :uuid, :state, :leaid, :zipcode, :nces_district_id]
    import_options              = {:validate => false }
    Portal::District.import(portal_district_field_names, district_values, import_options)
  end

  def load_districts
    nces_districts        = Portal::Nces06District.select("id, NAME, LEAID, LZIP, LSTATE")
    nces_district_ids     = nces_districts.map { |d| d.id }
    existing_districts    = Portal::District.where(:nces_district_id => nces_district_ids)
    existing_district_ids = existing_districts.map { |d| d.nces_district_id }

    Rails.logger.info "found    : #{nces_districts.size} national districts to import"
    Rails.logger.info "rejecting: #{existing_district_ids.size} pre-imported districts"

    nces_districts.reject! { |d| existing_district_ids.include? d.id }

    Rails.logger.info "leaves   : #{nces_districts.size} remaining districts to import"

    district_values = []
    nces_districts.each_with_index do |nces_district,count|
      tick count
      existing_district = Portal::District.where(:leaid=> nces_district.LEAID).first
      existing_district ||= Portal::District.where(:state => nces_district.LSTATE, :name => nces_district.NAME).first
      if existing_district
        Rails.logger.info "district similar already exists:#{existing_district.state} #{existing_district.name} #{existing_district.id}"
        Rails.logger.info "updating."
        existing_district.nces_district = nces_district
        existing_district.leaid = nces_district.LEAID
        existing_district.save
      else
        district_values << [
          nces_district.capitalized_name,
          UUIDTools::UUID.timestamp_create.to_s,
          nces_district.LSTATE,
          nces_district.LEAID,
          nces_district.LZIP,
          nces_district.id
        ]
      end
    end
    _import_districts(district_values)
  end

  def load_schools
    districts_map = {}
    Portal::District.select("id, nces_district_id").each do |d|
      next unless d.nces_district_id
      districts_map[d.nces_district_id] = d.id
    end
    nces_schools = Portal::Nces06School.select("id, nces_district_id, NCESSCH, LZIP, LEAID, SCHNAM, LSTATE")
    nces_school_ids     = nces_schools.map { |s| s.id }

    existing_schools    = Portal::School.where(:nces_school_id => nces_school_ids).select("id, nces_school_id")
    existing_school_ids = existing_schools.map { |s| s.nces_school_id }
    import_count = nces_schools.size - existing_school_ids.size
    Rails.logger.info "found    : #{nces_schools.size} national schools to import"
    Rails.logger.info "found    : #{existing_school_ids.size} pre-imported schools"
    Rails.logger.info "         : #{import_count} schools will be imported"

    school_values = []
    added = 0
    # this seems inefficient, but nces_schools.reject! was also really slow.
    nces_schools.each_with_index do |nces_school,count|
      tick count

      break if added >= import_count
      if existing_school_ids.include? nces_school.id
        tick(count,25,'.')
        next
      end
      tick(count,25,'+')

      added = added + 1
      district_id = districts_map[nces_school.nces_district_id]
      existing_school ||= Portal::School.where(:district_id => district_id,
                                               :name        => nces_school.SCHNAM).first
      if existing_school
        Rails.logger.info "similar school already exists:#{existing_school.state} #{existing_school.name} #{existing_school.id}"
        Rails.logger.info "updating."
        existing_school.nces_school = nces_school
        existing_school.save
      else
        school_values << [
          nces_school.capitalized_name,
          UUIDTools::UUID.timestamp_create.to_s,
          nces_school.LSTATE,
          nces_school.NCESSCH,
          nces_school.LZIP,
          district_id,
          nces_school.id]
      end
    end
    _import_schools(school_values)
  end

end
