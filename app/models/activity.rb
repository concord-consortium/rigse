class Activity < ActiveRecord::Base
  belongs_to :user
  acts_as_replicatable

  default_value_for :procedures_opening, <<HEREDOC
  <p>What activities will you and your students do and how are they connected to the objectives?</p>
  <h4>What will you be doing?</h4>
  <ul>
    <li>How do you activate and assess students’ prior knowledge and connect it to this new learning?</li>
    <li>How do you get students engaged in this lesson?</li>
  </ul>
  <p></p>
  <h4>Students will discuss the following driving question:</h4>
  <ul>
    <li>Key components:</li>
    <li>Starting conditions:</li>
  </ul>
  <p></p>
HEREDOC
  
  
end