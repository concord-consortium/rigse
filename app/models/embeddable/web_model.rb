class Embeddable::WebModel < ActiveRecord::Base
  set_table_name "embeddable_web_models"

  belongs_to :user
  belongs_to :web_model, :class_name => "::WebModel", :foreign_key => "web_model_id"

  has_many :page_elements, :as => :embeddable
  has_many :pages, :through =>:page_elements

  validates_presence_of :web_model, :unless   => :use_custom_url?
  validates_presence_of :web_content_url, :if => :use_custom_url?
  validate :web_content_url_is_a_url

  default_value_for :web_model do
    ::WebModel.find(:first)
  end

  include Changeable
  acts_as_replicatable

  self.extend SearchableModel
  @@searchable_attributes = %w{uuid}

  include ActionView::Helpers

  class <<self
    def searchable_attributes
      @@searchable_attributes
    end
  end

  def self.display_name
    "Web Model"
  end

  def url
    if use_custom_url?
      self.web_content_url
    else
      self.web_model.url
    end
  end
  
  def image_url
    if use_custom_url?
      url_for('/images/custom_web_model.png')
    else
      self.web_model.image_url
    end
  end
  
  def description
    if use_custom_url?
      "custom web model"
    else
      self.web_model.description
    end
  end
  
  def name
    if use_custom_url?
      self.web_content_url
    else
      self.web_model.name
    end
  end

  def investigations
    invs = []
    self.pages.each do |page|
      inv = page.investigation
      invs << inv if inv
    end
  end
  
  def use_custom_url?
    self.use_custom_url
  end
  
  def web_content_url_is_a_url
    return true unless self.use_custom_url?
    if UrlChecker.invalid?(self.web_content_url)
      errors.add_to_base("invalid web content url: #{self.web_content_url}")
      false
    else
      true
    end
  end
  
end
