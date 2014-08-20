class API::V1::SchoolRegistration
  include ActiveModel::Validations
  include ActiveModel::Validations::Callbacks
  include Virtus.model

  attr_reader :school

  attribute :school_name, String
  attribute :district_id, Integer

  validates :school_name, presence: { message: "You must provide a school name" }
  validate  :district_id_checker
  validate  :school_is_valid

  def district_id_checker
    return true if Portal::District.exists?(self.district_id)
    self.errors.add(:district_id, "You must select a valid district")
    return false
  end

  def new_school
    Portal::School.new(name: school_name, district_id: district_id)
  end

  def school_is_valid
    s = new_school
    return true if s.valid?
    s.errors.each do |field, value|
      if self.errors[field].blank?
        self.errors.add(field, s.errors.full_message(field, value))
      end
    end
    return false
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
  end

  def persist!
    persist_school
  end

end
