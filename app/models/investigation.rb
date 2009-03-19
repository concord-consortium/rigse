class Investigation < ActiveRecord::Base
  belongs_to :user
  has_many :sections, :order => :position, :dependent => :destroy
  acts_as_replicatable
  
  self.extend SearchableModel
  
  @@searchable_attributes = %w{title context opportunities objectives procedures_opening procedures_engagement procedures_closure assessment reflection}
  
  class <<self
    def searchable_attributes
      @@searchable_attributes
    end
  end
  
  

  default_value_for :procedures_opening, <<HEREDOC
  <h3>Procedures</h3>  
  <p><em>What investigations will you and your students do and how are they connected to the objectives?</em></p>
  <p></p>
  <h4>What will you be doing?</h4>
  <p><em>How do you activate and assess students’ prior knowledge and connect it to this new learning?</em></li>
  <p></p>
  <p><em>How do you get students engaged in this lesson?</em></li>
  <p></p>
  <h4>What will the students be doing?</h4>
  <p><em>Students will discuss the following driving question:</em></p>
  <p></p>
  <p><em>Key components:</p>
  <p></p>
  <p><em>Starting conditions:</p>
  <p></p>
  <p><em>Ability to change variables:</p>
  <p></p>
HEREDOC

  default_value_for :procedures_engagement, <<HEREDOC
  <h3>Engagement</h3>  
  <h4>What will you be doing?</h4>
  <p><em>What questions can you pose to encourage students to take risks and to deepen students’ understanding?</em></p>
  <p></p>
  <p><em>How do you facilitate student discourse?</em></p>
  <p></p>
  <p><em>How do you facilitate the lesson so that all students are active learners and reflective during this lesson?</em></p>
  <p></p>
  <p><em>How do you monitor students’ learning throughout this lesson?</em></p>
  <p></p>
  <p><em>What formative assessment is imbedded in the lesson?</em></p>
  <p></p>
  <h4>What will the students be doing?</h4>
  <p></p>
HEREDOC

  default_value_for :procedures_closure, <<HEREDOC
  <h3>Closure</h3>  
  <h4>What will you be doing?</h4>
  <p><em>What kinds of questions do you ask to get meaningful student feedback?</em></p>
  <p></p>
  <p><em>What opportunities do you provide for students to share their understandings of the task(s)?</em></p>
  <p></p>
  <h4>What will the students be doing?</h4>
  <p></p>
HEREDOC



  default_value_for :sections do 
    results = []
    i = 0
    %w[Discovery Matrials Safety Prediction Inestigation Analysis Conclusion].each do | section |
      i = i.next
      results << Section.new(
        :position => i,
        :name => section,
        :description => "#{section} section"
      )
    end
    results
  end

end


# 
# Recent Schema definition:
#
# create_table "investigations", :force => true do |t|
#   t.integer  "user_id"
#   t.string   "title"
#   t.text     "context"
#   t.text     "opportunities"
#   t.text     "objectives"
#   t.text     "procedures_opening"
#   t.text     "procedures_engagement"
#   t.text     "procedures_closure"
#   t.text     "assessment"
#   t.text     "reflection"
#   t.string   "uuid",                  :limit => 36
#   t.datetime "created_at"
#   t.datetime "updated_at"
# end
