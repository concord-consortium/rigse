class API::V1::UserRegistration
  include ActiveModel::Validations
  include ActiveModel::Validations::Callbacks
  include Virtus.model
  
  attr_reader :user

  attribute :first_name,            String
  attribute :last_name,             String
  attribute :password,              String
  attribute :password_confirmation, String
  attribute :email,                 String
  attribute :login,                 String

  validate  :user_is_valid

  before_validation :set_defaults

  def set_defaults
    self.password_confirmation = self.password
  end

  def password_confirmation
    return password
  end

  def user_params
    valid_keys = [:first_name, :last_name, :password, :password_confirmation, :email, :login]
    self.attributes.select { |k,v| valid_keys.include? k }
  end

  def user
    User.new(user_params)
  end

  def user_is_valid
    u = user
    return true if u.valid?
    u.errors.each do |err|
      self.errors.add err
    end
    return false
  end

  def save
    if valid?
      persist!
      true
    else
      false
    end
  end

  private

  def persist!
    @user = user
    @user.save!
  end


end