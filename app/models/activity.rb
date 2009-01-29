class Activity < ActiveRecord::Base
  belongs_to :user
  acts_as_replicatable

  default_value_for :procedures_opening, <<HEREDOC
  <h3>Procedures</h3>  
  <p>What activities will you and your students do and how are they connected to the objectives?</p>
  <p></p>
  <h4>What will you be doing?</h4>
  <p>How do you activate and assess students’ prior knowledge and connect it to this new learning?</li>
  <p></p>
  <p>How do you get students engaged in this lesson?</li>
  <p></p>
  <h4>Students will discuss the following driving question:</h4>
  <p>Key components:</p>
  <p></p>
  <p>Starting conditions:</p>
  <p></p>
  <p>Ability to change variables:</p>
  <p></p>
HEREDOC

  default_value_for :procedures_engagement, <<HEREDOC
  <h3>Engagement</h3>  
  <p>What questions can you pose to encourage students to take risks and to deepen students’ understanding? </p>
  <p></p>
  <p>How do you facilitate student discourse?</p>
  <p></p>
  <p>How do you facilitate the lesson so that all students are active learners and reflective during this lesson?</p>
  <p></p>
  <p>How do you monitor students’ learning throughout this lesson?</p>
  <p></p>
  <p>What formative assessment is imbedded in the lesson?</p>
  <p></p>
HEREDOC

  default_value_for :procedures_closure, <<HEREDOC
  <h3>Closure</h3>  
  <p>What kinds of questions do you ask to get meaningful student feedback? </p>
  <p></p>
  <p>What opportunities do you provide for students to share their understandings of the task(s)?</p>
  <p></p>
HEREDOC

end