# Add some investigation functionality to the User model
User.class_eval do
  has_many :investigations
  has_many :activities
  has_many :sections
  has_many :pages
  
  has_many :data_collectors
  has_many :xhtmls
  has_many :open_responses
  has_many :multiple_choices
  has_many :data_tables
  has_many :drawing_tools
  has_many :mw_modeler_pages
  has_many :n_logo_models
  
  # has_many :assessment_targets
  # has_many :big_ideas
  # has_many :domains
  # has_many :expectations
  # has_many :expectation_stems
  # has_many :grade_span_expectations
  # has_many :knowledge_statements
  # has_many :unifying_themes
  
  include Changeable
  
  def removed_investigation
    unless self.has_investigations?
      self.remove_role('author')
    end
  end
  
  def has_investigations?
    investigations.length > 0
  end
  
  # return the user who is the site administrator
  def self.site_admin
    User.find_by_email(APP_CONFIG[:admin_email])
  end
end