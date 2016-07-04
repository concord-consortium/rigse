class API::V1::SchoolRegistration
  include ActiveModel::Validations
  include ActiveModel::Validations::Callbacks
  include Virtus.model

  attr_reader :school

  attribute :school_name, String
  attribute :zipcode, String
  attribute :country_id, Integer
  attribute :school_id, Integer

  validate  :school_is_valid

  def self.for_country_and_zipcode(country_id, zipcode)
    @schools = Portal::School.where('country_id' => country_id, 'zipcode' => zipcode)
    @schools.order(:name).map { |s| API::V1::SchoolRegistration.json_data(s) }
  end

  def self.find(params)
    Portal::School.where('name' => params[:school_name],
                         'country_id' => params[:country_id],
                         'zipcode' => params[:zipcode])
                  .first
  end

  def self.json_data(school)
    name = school.name
    {name: name, id: school.id}
  end

  def new_school
    Portal::School.new(name: school_name, zipcode: zipcode, country_id: country_id)
  end

  def school_is_valid
    valid = true
    required_non_blank = {school_name: "School Name", country_id: "Country", zipcode: "Zip code"}
    required_non_blank.each do |k,v| 
      if self.send(k).blank?
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
