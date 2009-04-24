module InvestigationHelper
  def easy_xml(investigation)
    investigation.to_xml(
      :include => {
        :teacher_notes=>{
          :except => [:id,:authored_entity_id, :authored_entity_type]
        }, 
        :sections => {
          :exlclude => [:id,:investigation_id],
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
    )
  end
end