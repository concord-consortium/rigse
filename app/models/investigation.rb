class Investigation < ActiveRecord::Base

  belongs_to :user
  belongs_to :grade_span_expectation
  has_many :activities, :order => :position, :dependent => :destroy
  has_many :teacher_notes, :as => :authored_entity
  has_many :author_notes, :as => :authored_entity
  
  has_many :data_collectors,
     :finder_sql => 'SELECT data_collectors.* FROM data_collectors
     INNER JOIN page_elements ON data_collectors.id = page_elements.embeddable_id AND page_elements.embeddable_type = "DataCollector"
     INNER JOIN pages ON page_elements.page_id = pages.id    
     INNER JOIN sections ON pages.section_id = sections.id  
     INNER JOIN activities ON sections.activity_id = activity.id  
     WHERE activity.investigatio_id = #{id}'  
  
  acts_as_replicatable
  
  include Changeable
  include Noteable # convinience methods for notes...
  
  self.extend SearchableModel
  @@searchable_attributes = %w{name description}
  
  class <<self
    def searchable_attributes
      @@searchable_attributes
    end
  end
  
  def self.display_name
    'Investigation'
  end
  
  def left_nav_panel_width
     300
  end
  
  
  def deep_set_user user
    self.user = user
    self.activities.each do |a| 
      a.deep_set_user(user)
    end
  end
  
  
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
