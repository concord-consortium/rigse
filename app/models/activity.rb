class Activity < ActiveRecord::Base
  belongs_to :user
  belongs_to :investigation
  belongs_to :original
  has_many :sections, :order => :position, :dependent => :destroy
  has_many :pages, :through => :sections
  has_many :teacher_notes, :as => :authored_entity
  has_many :author_notes, :as => :authored_entity
  
  [DataCollector, BiologicaOrganism].each do |klass|
    eval "has_many :#{klass.table_name},
      :finder_sql => 'SELECT #{klass.table_name}.* FROM #{klass.table_name}
      INNER JOIN page_elements ON #{klass.table_name}.id = page_elements.embeddable_id AND page_elements.embeddable_type = \"#{klass.to_s}\"
      INNER JOIN pages ON page_elements.page_id = pages.id 
      INNER JOIN sections ON pages.section_id = sections.id  
      WHERE sections.activity_id = \#\{id\}'"
  end
  
  include Noteable # convinience methods for notes...
  
  acts_as_replicatable
  
  include Changeable
  
  self.extend SearchableModel
  
  @@searchable_attributes = %w{name description}
  
  class <<self
    def searchable_attributes
      @@searchable_attributes
    end
  end
  
  def parent
    return investigation
  end
  
  def teacher_note
    if teacher_notes[0]
      return teacher_notes[0]
    end
    teacher_notes << TeacherNote.create
    return teacher_notes[0]
  end
  
  def self.display_name
    'Activity'
  end
  
  def left_nav_panel_width
    300
  end
  
  def deep_set_user user
    self.user = user
    self.sections.each do |s|
      s.deep_set_user(user)
    end
  end
  
    
  def deep_xml
    self.to_xml(
      :include => {
        :teacher_notes=>{
          :except => [:id,:authored_entity_id, :authored_entity_type]
        }, 
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
    )
  end
    
@@opening_xhtml= <<HEREDOC
  <h3>Procedures</h3>  
  <p><em>What activities will you and your students do and how are they connected to the objectives?</em></p>
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

@@engagement_xhtml= <<HEREDOC
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

@@closure_xhtml= <<HEREDOC
  <h3>Closure</h3>  
  <h4>What will you be doing?</h4>
  <p><em>What kinds of questions do you ask to get meaningful student feedback?</em></p>
  <p></p>
  <p><em>What opportunities do you provide for students to share their understandings of the task(s)?</em></p>
  <p></p>
  <h4>What will the students be doing?</h4>
  <p></p>
HEREDOC


    
  # default_value_for :name do
  #   "New Activity"
  # end
  # 
  # default_value_for :description do
  #   "Describe the purpose and goals of the invesigation here."
  # end
  # 
  # default_value_for :sections do
  #   new_section = Section.create(
  #     :name => 'First Section',
  #     :description => 'What will the student investigate?' )
  #   [new_section]
  # end

  # 
  # default_value_for :name do
  #   "Making Mutations"
  # end
  # 
  # default_value_for :description do
  #   "In this activity you will get a chance to make different types of mutations in a computer model."
  # end
  # 
  # default_value_for :sections do 
  #   results = []
  #   results << Activity.make_summary
  #   results << Activity.make_engage
  #   results << Activity.make_explore
  #   results << Activity.make_engage2
  #   results << Activity.make_explore2
  #   results << Activity.make_wrap_up  
  #   results
  # end
  # 
  # protected 
  # 
  # ##
  # ##
  # ##
  # def Activity.make_summary
  #    summary = Section.create(
  # 
  #       :name => 'Summary',
  #       :description => 'What will the student investigate?'
  #     )
  #     page_one = Page.create(
  #       :name => "Page 1",
  #       :description => "First Page"
  #     )
  #     xhtml = Xhtml.create(
  #       :name => "Summary",
  #       :description => "In this activity you will get a chance to make different types of mutations in a computer model.",
  #       :content => <<-HERE
  #         <p>
  #           In this activity you will get a chance to make different types of mutations in a computer model.
  #         </p>
  #       HERE
  #     )
  #     xhtml.pages << page_one
  #     xhtml.save
  #     summary.pages << page_one
  #     summary
  # end
  # 
  # 
  # ##
  # ##
  # ##
  # def Activity.make_engage
  #   engage = Section.create(
  #  
  #      :name => 'Engage',
  #      :description => 'Discovery question; what do you already know; what real-life situations does this experiment relate to? Predictions.'
  #    )
  #    page_one = Page.create(
  #      :name => "Page 1",
  #      :description => "First Page"
  #    )
  #    xhtml = Xhtml.create(
  #      :name => "Engage",
  #      :description => "In this activity you will get a chance to make different types of mutations in a computer model.",
  #      :content => <<-HERE
  #        <p>
  #         In this activity you will get a chance to make different types of mutations in a computer model.<br/>
  #         <img src="http://itsi.concord.org/share/mw_activities/protein_structure/dna_mutations/mutation.jpg">
  #         In the following blanks, answer the questions by taking notes as the class discusses them: <br/>
  #        </p>
  #      HERE
  #    )
  #    xhtml.pages << page_one
  #    xhtml.save
  # 
  #    [
  #      'What is a mutation?',
  #      'What effect does a mutation have?',
  #      'Do you know of any diseases that are caused by a mutation?',
  #      'How does this mutation cause the disease?',
  #      'Do mutations always cause a disease?',
  #      'How common are mutations? Do I have one?',
  #      'What causes a mutation to occur?'
  #    ].each do |question_text|
  #      open_response = OpenResponse.create(
  #       :name => 'open reponse', 
  #       :description =>'open response question',
  #       :prompt => "<p>#{question_text}</p>",
  #       :default_response => "Write your answer here")
  #      open_response.pages << page_one
  #      open_response.save
  #    end
  #    engage.pages << page_one
  #    engage
  # end
  # 
  # ##
  # ##
  # ##
  # def Activity.make_explore
  #   explore = Section.create(
  #  
  #      :name => 'Explore',
  #      :description => 'Procedure; prediction; Data collection; experiment with model; record observations.'
  #    )
  #    page_one = Page.create(
  #      :name => "Page 1",
  #      :description => "First Page"
  #    )
  #    open_response = OpenResponse.create(
  #     :name => 'open reponse', 
  #     :description =>'open response question',
  #     :prompt => "<p>Give an example of a mutation to the following DNA sequence:</p><p><code>ATTGCA</code></p>",
  #     :default_response => "Write  answer here")
  #    open_response.pages << page_one
  #    open_response.save
  #    
  #    xhtml = Xhtml.create(
  #      :name => "Explore",
  #      :description => "In this activity you will get a chance to make different types of mutations in a computer model.",
  #      :content => <<-HERE
  #        <p>
  #        With the model below, you’ll get to make substitution mutations, 
  #        replacing one DNA nucleotide with another. 
  #        Substitution mutations are usually caused by an error in the DNA replication process. 
  #        As the DNA strand is copied, the wrong nucleotide is inserted.
  #        </p>
  #        <ol>
  #           <li>Synthesize a protein from the given DNA sequence by pressing the transcribe and translate buttons.</li>
  #           <li>Pause the model and find the second amino acid in the chain. It's labeled “Phe," meaning it is a phenylalanine. It's pink, meaning it's hydrophobic. This is the amino acid you will replace by making a mutation.</li>
  #           <li>Take a snapshot and use the arrow tool to point out the Phe.Press reset.</li>
  #           <li>The second DNA triplet codes for the phenylalanine. Find the second nucleotide of its triplet, on the bottom strand (it's the fifth nucleotide from the left, an A).</li>
  #           <li>Hold down the *control* key and click on this nucleotide, and select a substitution mutation to change it from T to G.</li>
  #           <li>Synthesize your mutant protein by pressing the transcribe and translate buttons.</li>
  #           <li>Take a snapshot and point out three things:</li>
  #           <ol>
  #             <li>the mutation in the DNA,</li>
  #             <li>the resulting change in the RNA,</li>
  #             <li>the resulting change in the protein.</li>
  #             <li>Click the reset button.</li>
  #           <ol>
  #           <li>Now make a mutation that causes NO amino acid change in the protein. Use the genetic code table (need link here) to find a triplet you can change but that will leave the same amino acids present. If you get stuck, press reset to get back the original DNA sequence.</li>
  #           <li>Synthesize your new protein.</li>
  #           <li>Take a snapshot and point out the change in the DNA and the RNA (remember, the protein should not have changed).</li>
  #         </ol>
  #         <img src="http://itsi.concord.org/share/mw_activities/protein_structure/dna_mutations/key.jpg">
  #      HERE
  #    )
  #    xhtml.pages << page_one
  #    xhtml.save
  #    
  #    xhtml2 = Xhtml.create(
  #       :name => "Explore",
  #       :description => "In this activity you will get a chance to make different types of mutations in a computer model.",
  #       :content => <<-HERE
  #         <p>
  #         Answer these questions in your own words. 
  #         Think about whether you can answer them differently 
  #         now than you did before using the model.
  #         </p>
  #       HERE
  #     )
  #     xhtml2.pages << page_one
  #     xhtml2.save
  #     
  #    [
  #      'What is a mutation?',
  #      'What effect does a mutation have?',
  #    ].each do |question_text|
  #      open_response = OpenResponse.create(
  #       :name => 'open reponse', 
  #       :description =>'open response question',
  #       :prompt => "<p>#{question_text}</p>",
  #       :default_response => "Write your answer here")
  #      open_response.pages << page_one
  #      open_response.save
  #    end
  #    explore.pages << page_one
  #    explore
  # end
  # 
  # ##
  # ##
  # ##
  # def Activity.make_engage2
  #   engage = Section.create(
  #  
  #      :name => 'Engage (second section)',
  #      :description => 'Discovery question; what do you already know; what real-life situations does this experiment relate to? Predictions.'
  #    )
  #    page_one = Page.create(
  #      :name => "Page 1",
  #      :description => "First Page"
  #    )
  #    xhtml = Xhtml.create(
  #      :name => "Engage (second section)",
  #      :description => "In this activity you will get a chance to make different types of mutations in a computer model.",
  #      :content => <<-HERE
  #        <p>
  #         In the next model, you’ll get to create both insertion and deletion mutations. 
  #         Insertion mutations add nucleotides into the sequence: for example, changing ATCG to ATACG. 
  #         Deletion mutations remove nucleotides from the sequence: for example, changing ATCG to ACG. 
  #        </p>
  #      HERE
  #    )
  #    xhtml.pages << page_one
  #    xhtml.save
  # 
  #    [
  #      'Give an example of an insertion mutation to the following DNA sequence: ATTGCA',
  #      'What will happen to the mRNA transcribed from the DNA with the insertion?',
  #      'Predict the sequence of the RNA.',
  #      'What will happen to the protein?'
  #    ].each do |question_text|
  #      open_response = OpenResponse.create(
  #       :name => 'open reponse', 
  #       :description =>'open response question',
  #       :prompt => "<p>#{question_text}</p>",
  #       :default_response => "Make a prediction here")
  #      open_response.pages << page_one
  #      open_response.save
  #    end
  #    engage.pages << page_one
  #    engage
  # end  
  # 
  # 
  # ##
  # ##
  # ##
  # def Activity.make_explore2
  #   explore = Section.create(
  #  
  #      :name => 'Explore (second section)',
  #      :description => 'Procedure; prediction; Data collection; experiment with model; record observations.'
  #    )
  #    page_one = Page.create(
  #      :name => "Page 1",
  #      :description => "First Page"
  #    )
  #   
  #    xhtml = Xhtml.create(
  #      :name => "Explore (second section)",
  #      :description => "In this activity you will get a chance to make different types of mutations in a computer model.",
  #      :content => <<-HERE
  #        <p>
  #         A "reading frame" is the organization of the DNA into triplets, 
  #         which are groups of three nucleotides that code for a single amino acid. 
  #        </p>
  #        <ol>
  #           <li>Synthesize the protein.</li>
  #           <li>Make an insertion mutation somewhere in the first half of the sequence by holding down the <b>control</b> key and clicking on a nucleotide to make a mutation. Then choose a mutation from the pop-up menu. . You should see a frame-shift occur.</li>
  #           <li>Synthesize your mutant protein.</li>
  #           <li>Press reset. </li>
  #           <li>Make a combination of insertions or deletions, such that no frame-shift occurs. Here are two ways to make mutations that do not cause a frame-shift: by making three insertions in a row, creating a new triplet or by making three deletions, so you remove an entire triplet. </li>
  #           <li>Synthesize your mutant protein.</li>
  #          
  #         <img src="http://itsi.concord.org/share/mw_activities/protein_structure/dna_mutations/key.jpg">
  #         MODEL: Protein Structure – Mutation insertion and Deletion model 2 (MW model listed in ITSI DIY)
  # 
  #      HERE
  #    )
  #    xhtml.pages << page_one
  #    xhtml.save
  #    
  #    [
  #      'Give an example of an insertion mutation to the following DNA sequence: ATTGCA',
  #      'What will happen to the mRNA transcribed from the DNA with the insertion?',
  #      'Predict the sequence of the RNA.',
  #      'What will happen to the protein?'
  #    ].each do |question_text|
  #      open_response = OpenResponse.create(
  #       :name => 'open reponse', 
  #       :description =>'open response question',
  #       :prompt => "
  #         <dl>
  #           <dt>#{question_text}<dt>
  #           <dd>
  #             Your answer was:XXXXXX </br>
  #             Do you still agree with your answer? 
  #           </dd>
  #         </dl>
  #       ",
  #       :default_response => "If not, put your new answer here")
  #      open_response.pages << page_one
  #      open_response.save
  #    end
  #    explore.pages << page_one
  #    explore
  # end
  # 
  # 
  # 
  # ##
  # ##
  # ##
  # def Activity.make_wrap_up
  #   wrap_up = Section.create(
  #     :name => 'Wrap-up',
  #     :description => 'This section contains notes and materials for the teacher only.'
  #   )
  # 
  #   page = Page.create(
  #     :name => "Page 1",
  #     :description => "What activities will you and your students do and how are they connected to the objectives?"
  #   )
  #   
  #   xhtml = Xhtml.create(
  #     :name => "Opening Proceedure",
  #     :description => "What activities will you and your students do and how are they connected to the objectives?",
  #     :content => <<-DONE
  #       <p>
  #       Let’s look at a real protein and a mutation in it that causes a disease.
  #       </p>
  #       <p>
  #       [MODEL: Hemoglobin – exists somewhere in MW already. Let’s just use a marker for now. ]
  #       </p>
  # 
  #       <p><strong>NOTE:</strong>This image not cleared for republication.</p>
  #       <img src="http://carnegieinstitution.org/first_light_case/horn/lessons/images/red%20blood%20cells.JPG">
  #     
  #     DONE
  #   )
  #   xhtml.pages << page
  #   xhtml.save
  #   wrap_up.pages << page 
  #   wrap_up
  # end
  
  def teacher_note
    if teacher_notes[0]
      return teacher_notes[0]
    end
    teacher_notes << TeacherNote.create
    return teacher_notes[0]
  end

  ## in_place_edit_for calls update_attribute.
  def update_attribute(name, value)
    update_investigation_timestamp if super(name, value)
  end

  ## Update timestamp of investigation that the activity belongs to 
  def update_investigation_timestamp
    investigation = self.investigation
    if investigation
      investigation.update_attributes(:updated_at => Time.now)
      investigation.save!
    end
  end
    
end


# 
# Recent Schema definition:
#
# create_table "activities", :force => true do |t|
#   t.integer  "user_id"
#   t.string   "name"
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
