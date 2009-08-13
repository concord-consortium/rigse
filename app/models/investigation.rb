class Investigation < ActiveRecord::Base
  
  cattr_accessor :publication_states
  
  belongs_to :user
  belongs_to :grade_span_expectation
  has_many :activities, :order => :position, :dependent => :destroy
  has_many :teacher_notes, :as => :authored_entity
  has_many :author_notes, :as => :authored_entity

  [DataCollector, BiologicaOrganism, BiologicaWorld].each do |klass|
    eval "has_many :#{klass.table_name},
      :finder_sql => 'SELECT #{klass.table_name}.* FROM #{klass.table_name}
      INNER JOIN page_elements ON #{klass.table_name}.id = page_elements.embeddable_id AND page_elements.embeddable_type = \"#{klass.to_s}\"
      INNER JOIN pages ON page_elements.page_id = pages.id 
      INNER JOIN sections ON pages.section_id = sections.id
      INNER JOIN activities ON sections.activity_id = activities.id
      WHERE activities.investigation_id = \#\{id\}'"
  end
  
  has_many :page_elements,
    :finder_sql => 'SELECT page_elements.* FROM page_elements
    INNER JOIN pages ON page_elements.page_id = pages.id 
    INNER JOIN sections ON pages.section_id = sections.id
    INNER JOIN activities ON sections.activity_id = activities.id
    WHERE activities.investigation_id = #{id}'
  
  acts_as_replicatable

  # use rubyist-aasm gem (acts_as_state_machine) 
  # for publication status:
  # see: http://www.practicalecommerce.com/blogs/post/440-Acts-As-State-Machine-Is-Now-A-Gem
  # and http://www.ruby-forum.com/topic/179721
  # for a discussion on how the new aasm gem differs from the old plugin...
  include AASM 
  aasm_initial_state :draft
  aasm_column :publication_status
  @@publication_states = [:draft,:published,:private]
  @@publication_states.each { |s| aasm_state s}

  aasm_event :publish do
    transitions :to => :published, :from => [:draft]
  end
  
  aasm_event :un_publish do
    transitions :to => :draft, :from => [:published]
  end  
  # end acts_as_state_machine stuff
  
  # for convinience (will not work in find_by_* &etc.)
  [:grade_span, :domain].each { |m| delegate m, :to => :grade_span_expectation }
  
  #
  # IMPORTANT: Use with_gse if you are also going to use domain and grade params... eg:
  # Investigation.with_gse.grade('9-11') == good
  # Investigation.grade('9-11') == bad
  #
  named_scope :with_gse, {
    :joins => "JOIN grade_span_expectations on (grade_span_expectations.id = investigations.grade_span_expectation_id) JOIN assessment_targets ON (assessment_targets.id = grade_span_expectations.assessment_target_id) JOIN knowledge_statements ON (knowledge_statements.id = assessment_targets.knowledge_statement_id)"
  }
  
  named_scope :domain, lambda { |domain_id| 
    {
      :conditions =>[ 'knowledge_statements.domain_id = ?', domain_id]
    }
  }
  
  named_scope :grade, lambda { |gs|
    gs = gs.size > 0 ? gs : "%"
    {
      :conditions =>[ 'grade_span_expectations.grade_span LIKE ?', gs ]
    }
  }
  
  named_scope :published, 
  {
    :conditions =>{:publication_status => "published"}
  }

  named_scope :like, lambda { |name|
    name = "%#{name}%"
    {
     :conditions =>[ "investigations.name LIKE ? OR investigations.description LIKE ?", name,name]
    }
  }

  include Changeable
  include Noteable # convinience methods for notes...
  
  self.extend SearchableModel
  @@searchable_attributes = %w{name description publication_status}
  
  class <<self
    def searchable_attributes
      @@searchable_attributes
    end
  end
  
  # Enables a teacher note to call the investigation method of an
  # authored_entity to find the relavent investigation
  def investigation
    self
  end
  
  def self.find_by_grade_span_and_domain_id(grade_span,domain_id)
    @grade_span_expectations = GradeSpanExpectation.find(:all, :include =>:knowledge_statements, :conditions => ['grade_span LIKE ?', grade_span])
    @investigations = @grade_span_expectations.map { |gse| gse.investigations }.flatten.compact
    # @investigations.flatten!.compact!
  end
  
  
  def after_save
    if self.user
      self.user.add_role('author') 
    end
  end
  
  def self.display_name
    'Investigation'
  end
  
  def left_nav_panel_width
     300
  end
  
  def parent
    return nil
  end
  
  def children
    return activities
  end
  
  include TreeNode
  
  
  def deep_xml
    self.to_xml(
      :include => {
        :teacher_notes=>{
          :except => [:id,:authored_entity_id, :authored_entity_type]
        }, 
        :activities => {
          :exlclude => [:id,:investigation_id],
          :include => {
            :sections => {
              :exlclude => [:id,:activity_id],
              :include => {
                :teacher_notes=>{
                  :except => [:id,:authored_entity_id, :authored_entity_type]
                },
                :pages => {
                  :exlclude => [:id,:section_id],
                  :include => {
                    :teacher_notes=>{
                      :except => [:id,:authored_entity_id, :authored_entity_type]
                    },
                    :page_elements => {
                      :except => [:id,:page_id],
                      :include => {
                        :embeddable => {
                          :except => [:id,:embeddable_type,:embeddable_id]
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    )
  end
  
  
end
