class CommonsLicense < ActiveRecord::Base
  self.primary_key = :code
  before_save :default_paths
  attr_accessible :name, :code, :deed, :legal, :image, :description, :number

  Site = "creativecommons.org"

  ImageFormat = "http://i.#{Site}/l/%{code}/3.0/88x31.png"
  DeedFormat  =   "http://#{Site}/licenses/%{code}/3.0/"
  LegalFormat =   "http://#{Site}/licenses/%{code}/3.0/legalcode"

  default_scope :order => 'number ASC'

  def default_paths
    self.deed  ||= CommonsLicense.deed(self)
    self.legal ||= CommonsLicense.legal(self)
    self.image ||= CommonsLicense.image(self)
  end

  def self.for_select
    self.all.map { |l| [l.name,l.code] }
  end

  def self.url(license,fmt)
    modified_code = license.code.downcase
    modified_code.gsub!("cc-","")
    fmt % {:code => modified_code}
  end

  def self.image(license)
    url(license, ImageFormat)
  end

  def self.deed(license)
    url(license, DeedFormat)
  end

  def self.legal(license)
    url(license, LegalFormat)
  end

  # TODO: CRUD actions and views? Maybe not.
  def self.load_all_from_yaml!
    defs = YAML::load_file(File.join(Rails.root,"config","licenses.yml"));
    defs['licenses'].each do |license_hash|
      license = CommonsLicense.find_or_create_by_code(license_hash)
      license.update_attributes(license_hash)
      license.save
    end
  end

  self.load_all_from_yaml! rescue nil
end
