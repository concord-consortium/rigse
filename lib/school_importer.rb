#
# Import CSV data in the format of district,school
# 
# invoke with: 
# ./script/runner "SchoolImporter.run('resources/CohortSchools2010.csv')" 
# filename is assumed to be in Relaitve to RAILS_ROOT
# TODO: write a test

require 'fileutils'
require 'arrayfields'

class SchoolImporter
  attr_accessor :import_data
  attr_accessor :filename
  attr_accessor :schools
  attr_accessor :districts

  CVS_COLUMNS = [:district_name, :school_name]        # format of import CSV data
  BASE_DIR = "#{RAILS_ROOT}"                          # where to look for the file
  DEFAULT_FILENAME = "resources/CohortSchools2010.csv"# a sample file

  def self.run(filename=DEFAULT_FILENAME, delete_others=false)
    importer = self.new(filename)
    importer.read_file
    importer.parse_data
    if (delete_others)
      importer.delete_all_others!
    end
    self.title_case
    return importer
  end
  
  def self.title_case
    entities = Portal::School.all
    entities = entities + Portal::District.all

    entities.each do |e|
      e.name = e.name.titlecase.strip
      e.save
    end
    entities.map! { |e| e.name }
    entities.sort.each { |e| puts e }
    nil
  end
  
  def initialize(csv_filename=DEFAULT_FILENAME)
    self.filename = csv_filename
    self.schools = {}
    self.districts = {}
  end

  def read_file
    local_path = "#{BASE_DIR}/#{self.filename}"
    File.open(local_path,"r") do |f|
      self.import_data = f.read
      log("data read complete")
    end
  end

  def parse_data
    self.import_data.each_line do |line|
      add_csv_row(line)
    end
  end
  
  def add_csv_row(line)
    FasterCSV.parse(line) do |row|
      if row.class == Array
        row.fields = CVS_COLUMNS
        school_for(row)
      else
        log("unable to parse line #{line}")
      end
    end
  end
   
  def log(message, opts = {})
    puts(message)
  end
  
  def district_for(row)
    district_name = row[:district_name].titlecase.strip
    cached_district = self.districts[:district_name]
    if cached_district
      log("District cache hit")
      return cached_district
    end

    nces_district = Portal::Nces06District.find(:first, :conditions => ["NAME = ?", "#{district_name.upcase.strip}"]);
    if nces_district
      district = Portal::District.find_or_create_by_nces_district(nces_district)
    else
      district = Portal::District.find_by_name(district_name)
      if district
        log ("Found (non-NCES) district: #{district_name}")
      else
        district = Portal::District.create(:name => district_name);
        log("had to create a district named #{district_name}")
      end
    end
    self.districts[district_name] = district
    return district
  end

  def school_for(row)
    school_name = row[:school_name].titlecase.strip
    cached_school = self.schools[school_name]
    if cached_school
      log("School Cache hit for #{school_name}")
      return cached_school
    end
    nces_school = Portal::Nces06School.find(:first, :conditions => ["SCHNAM = ?", "#{school_name.upcase.strip}"], :select => "id, nces_district_id, NCESSCH, SCHNAM")
    if nces_school
      school = Portal::School.find_or_create_by_nces_school(nces_school)
      log("found NCES school: #{school_name}")
    else
      school = Portal::School.find_by_name(school_name)
      if school
        log("found existing (non-NCES) school: #{school_name}")
      else 
        school = Portal::School.create( :name => school_name, :district => district_for(row))
        log("had to make new school: #{school_name}")
      end
    end
    self.schools[school_name] = school
    school
  end

  def delete_all_others!
    save_schools = self.schools.values
    site_school = Portal::School.find_by_name(APP_CONFIG[:site_school]) || Portal::School.first
    save_schools << site_school
    delete_schools = Portal::School.all - save_schools
    
    delete_schools.each do |s| 
      destroy_school(s, site_school)
    end

    delete_schools = Portal::School.all.select { |s| s.district.nil? }

    delete_schools.each do |s| 
      destroy_school(s,site_school)
    end
    
    delete_districts = Portal::District.all.select { |d| d.schools.size < 1 }
    delete_districts.each    { |d| d.destroy; puts "destroyed district #{d.name} with #{d.schools.size} schools" }
  end

  private
  def destroy_school(school,replacement)
    if replacement
      school.members.each do |m|
        m.schools = m.schools - [school]
          m.schools << replacement
          m.save
      end
    end
    school.destroy
    puts "destroyed school #{school.name} with #{school.members.size} members" 
  end
  
end
