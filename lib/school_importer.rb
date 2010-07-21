require 'fileutils'
require 'arrayfields'

class SchoolImporter
  attr_accessor :import_data
  attr_accessor :filename
  attr_accessor :schools
  attr_accessor :districts

  CVS_COLUMNS = [:district_name, :school_name]    # format of import CSV data
  BASE_DIR = "#{RAILS_ROOT}/resources/" # where to look for the file
  DEFAULT_FILENAME = "CohortSchools2010.csv"      # a reasonable default

  def initialize(csv_filename=DEFAULT_FILENAME)
    self.filename = csv_filename
    self.schools = {}
    self.districts = {}
  end

  def parse_csv_from_file
    local_path = "#{BASE_DIR}/#{self.filename}"
    File.open(local_path,"r") do |f|
      self.import_data = f.read
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
    district_name = row[:district_name]
    cached_district = self.districts[district_name]
    return cached_district unless cached_district
    nces_district = Portal::Nces06District.find(:first, :conditions => ["NAME like ?", "%#{district_name.upcase.strip}%"]);
    if nces_district
      district = Portal::District.find_or_create_by_nces_district(nces_district)
    else
      log("had to create a district named #{district_name}")
      district = Portal::District.find_or_create_by_name(:name => district_name);
    end
    self.districts[district_name] = district
    return district
  end

  def school_for(row)
    school_name = row[:school_name]
    cached_school = self.schools[school_name]
    return cached_school unless cached_school.nil?
    nces_school = Portal::Nces06School.find(:first, :conditions => ["SCHNAM like ?", "%#{school_name.upcase.strip}%"], :select => "id, nces_district_id, NCESSCH, SCHNAM")
    if nces_school
      school = Portal::School.find_or_create_by_nces_school(nces_school)
    else
      log("had to create a new school named #{school_name}") if school.new_record?
      school = Portal::School.find_or_create_by_name ( :name => school_name, :district => district_for(row) )
    end
    self.schools[school_name] = school
    school
  end
  
end
