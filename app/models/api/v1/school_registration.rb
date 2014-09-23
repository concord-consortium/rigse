class API::V1::SchoolRegistration
  include ActiveModel::Validations
  include ActiveModel::Validations::Callbacks
  include Virtus.model

  attr_reader :school

  attribute :school_name, String
  attribute :district_id, Integer
  attribute :country_id, Integer
  attribute :school_id, Integer
  attribute :state, String
  attribute :city, String

  validate  :school_is_valid

  def self.usa
    return @usa if @usa
    @usa = Portal::Country.find_by_two_letter('US').id
  end

  def self.international?(school)
    return school.country_id && school.country_id != API::V1::SchoolRegistration.usa
  end

  def self.for_district(district_id)
    @schools = Portal::School.where('district_id' => district_id)
    @schools.order(:name).map { |s| API::V1::SchoolRegistration.json_data(s) }
  end
  
  def self.for_country(country_id)
    @schools = Portal::School.where('country_id' => country_id)
    @schools.order(:name).map { |s| API::V1::SchoolRegistration.json_data(s) }
  end

  def self.json_data(school)
    name = school.name
    if international?(school)
      unless school.city.blank? 
        name = "#{name} (#{school.city})"
      end
    end
    {name: name, id: school.id}
  end

  def new_school
    Portal::School.new(name: school_name, district_id: district_id, state: state, city: city, country_id: country_id)
  end

  def international?
    API::V1::SchoolRegistration.international?(self)
  end

  def school_is_valid
    valid = true
    required_non_blank = {school_name: "School Name", state: "State", district_id: "District"}
    if international?
      required_non_blank[:country_id] = "Country"
      required_non_blank[:city] = "City"
      required_non_blank.delete(:district_id)
    end
    required_non_blank.each do |k,v| 
      if (self.send(k).blank?)
        self.errors.add(k, "You must specify a #{v}")
        valid = false
      end
    end
    valid
  end

  def name
    school_name
  end

  def save
    if valid?
      persist!
    else
      false
    end
  end

  protected

  def persist_school
    @school = new_school
    @school.save!
    self.school_id = @school.id
  end

  def persist!
    persist_school
  end

end
