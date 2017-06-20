class CommonsLicense < ActiveRecord::Base
  self.primary_key = :code
  before_save :default_paths
  attr_accessible :name, :code, :deed, :legal, :image, :description, :number

  Site = "creativecommons.org"

  ImageFormat = "http://i.#{Site}/l/%{code}/%{version}/88x31.png"
  DeedFormat  =   "http://#{Site}/licenses/%{code}/%{version}/"
  LegalFormat =   "http://#{Site}/licenses/%{code}/%{version}/legalcode"

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
    match = /^CC-(.+)\s+([0-9.]+)$/.match(license.code)
    if match
      fmt % {:code => match[1].downcase, :version => match[2]}
    else
      ""
    end
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
end
