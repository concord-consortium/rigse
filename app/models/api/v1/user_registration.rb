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
  attribute :asked_age,             Boolean, :default => false
  attribute :have_consent,          Boolean, :default => false

  validate  :user_is_valid

  before_validation :set_defaults

  def set_defaults
    self.password_confirmation = self.password
  end

  def password_confirmation
    return password
  end

  def user_params
    valid_keys = [:first_name, :last_name, :password, :password_confirmation, :email, :login, :asked_age, :have_consent]
    self.attributes.select { |k,v| valid_keys.include? k }
  end

  def new_user
    User.new(user_params)
  end

  def user_is_valid
    u = new_user
    return true if u.valid?
    u.errors.each do |err|
      self.errors.add err
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
  def persist_user
    @user = new_user
    @user.save!
  end

  def persist!
    persist_user
  end


end