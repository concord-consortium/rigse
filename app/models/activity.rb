class Activity < ActiveRecord::Base
  belongs_to :user
  has_many :sections, :order => :position, :dependent => :destroy
  has_many :teacher_notes, :as => :authored_entity
  acts_as_replicatable
  
  include Changeable
  
  self.extend SearchableModel
  
  @@searchable_attributes = %w{name description}
  
  class <<self
    def searchable_attributes
      @@searchable_attributes
    end
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
      s.user = user
      s.pages.each do |p|
        p.user = user
        p.page_elements.each do |e|
          if e.embeddable
            e.embeddable.user = user
          end
        end
      end
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

  # ITSIDIY_URL = ActiveRecord::Base.configurations['itsi']['asset_url']

  def self.process_textile_content(textile_content, split_last_paragraph=false)
    doc = Hpricot(RedCloth.new(textile_content).to_html)
    # if imaages use paths relative to the itsidiy make the full
    (doc/"img[@src]").each do |img|
      if img[:src][0..6] == '/images'
        img[:src] = ITSIDIY_URL + img[:src]
      end
    end
    # if split_last_paragraph is true then split the content at the
    # last paragraph and return the last paragraph in the second element
    if split_last_paragraph
      last_paragraph = (doc/"p:last-of-type").remove.to_html
      body = doc.to_html
      [body, last_paragraph]
    else
      [doc.to_html, '']
    end
  end

  def self.create_section(name, section_desc)
    section = Section.create do |s|
      s.name = name
      s.description = section_desc
    end
    section
  end
  
  def self.create_section_page(name, html_content='', section_description='', page_description='')
    page = Page.create do |p|
      p.name = "#{name}s"
      p.description = page_description
    end
    embeddable = Xhtml.create do |x|
      x.name = name + ": Body Content (html)"
      x.description = ""
      x.content = html_content
      embeddable.pages << page
    end
    section = Section.create do |s|
      s.name = name
      s.description = section_description
      s.pages << page
    end
    [section, page, page_element]
  end

  def self.add_page_to_section(section, name, html_content='', page_description='')
    if html_content.empty?
      page = Page.create do |p|
        p.name = "#{name}"
        p.description = page_description
      end
      [page, nil]
    else
      page_element = Xhtml.create do |x|
        x.name = name + ": Body Content (html)"
        x.description = ""
        x.content = html_content
      end
      page = Page.create do |p|
        p.name = "#{name}"
        p.description = page_description
        page_element.pages << p
      end
      [page, page_element]
    end
  end

  def self.add_open_response_to_page(page, question_prompt)
    page_element = OpenResponse.create do |o|
      o.name = page.name + ": Open Response Question"
      o.description = ""
      o.prompt = question_prompt
    end
    page_element.pages << page
  end

  def self.add_prediction_graph_response_to_page(page, question_prompt)
    page_element = DataCollector.create do |d|
      d.name = page.name + ": Prediction Graph Question"
      d.title = d.name
      d.description = "Still to be implemented: this should be converted into a real Prediction Graph response."
    end
    page_element.pages << page
  end

  def self.add_drawing_response_to_page(page, question_prompt)
    page_element = OpenResponse.create do |o|
      o.name = page.name + ": Drawing Question"
      o.description = "This should be converted into a Drawing response."
      o.prompt = question_prompt
      o.default_response = "Still to be implemented: later this will be a Drawing instead of an Open Response question ..."
    end
    page_element.pages << page
    # page_element = Drawing.create do |d|
    #   d.name = page.name
    #   d.description = ""
    # end
    # page_element.pages << page
  end

  def self.add_xhtml_to_page(page, html_content)
    page_element = Xhtml.create do |x|
      x.name = name + ": Body Content (html)"
      x.description = ""
      x.content = html_content
    end
  end

  def self.add_data_collector_to_page(page, probe_type, multiple_graphs)
    page_element = DataCollector.create do |d|
      d.name = page.name + ": #{probe_type.name} Data Collector"
      d.title = d.name
      d.probe_type = probe_type
      d.description = "This a Data Collector Graph that will collect data from a #{probe_type.name} sensor."
    end
    page_element.pages << page
  end

  def self.create_from_itsi(itsi_activity, rites_user)
    itsi_prefix = "ITSI: #{itsi_activity.id} - #{itsi_activity.name}"
    activity = Activity.create do |i|
      i.name = itsi_prefix
      i.user = rites_user
      i.description = itsi_activity.description
    end

    name = itsi_activity.name
    section_desc = "ITSI Activities have a series of pages in just one section"
    section = Activity.create_section(name, section_desc)
    activity.sections << section

    # introduction
    #   name: Introduction
    #   xhtml: introduction
    #   open_text_question
    #     introduction_text_response
    #   drawing
    #     introduction_drawing_response

    name = "Introduction"
    page_desc = "ITSI Activities start with a Discovery Question."
    extract_question_prompt = itsi_activity.introduction_text_response || itsi_activity.introduction_drawing_response
    body, question_prompt = Activity.process_textile_content(itsi_activity.introduction, extract_question_prompt)
    unless body.empty? && question_prompt.empty?
      page, page_element = Activity.add_page_to_section(section, name, body, page_desc)
      section.pages << page
      if itsi_activity.introduction_text_response
        Activity.add_open_response_to_page(page, question_prompt)
      end
      if itsi_activity.introduction_drawing_response
        Activity.add_drawing_response_to_page(page, question_prompt)
      end
    end

    # standards
    #   name: Standards
    #   xhtml: standards

    name = "Standards"
    page_desc = "What standards does this ITSI Activity cover?"
    body, question_prompt = Activity.process_textile_content(itsi_activity.standards)
    unless body.empty?
      page, page_element = Activity.add_page_to_section(section, name, body, page_desc)
      section.pages << page
    end

    # materials
    #   name: Materials
    #   xhtml: materials

    name = "Materials"
    page_desc = "What materials does this ITSI Activity require?"
    body, question_prompt = Activity.process_textile_content(itsi_activity.materials)
    unless body.empty?
      page, page_element = Activity.add_page_to_section(section, name, body, page_desc)
      section.pages << page
    end
  
    # safety
    #   name: Safety
    #   xhtml: safety

    name = "Safety"
    page_desc = "Are there any safety considerations to be aware of in this ITSI Activity?"
    body, question_prompt = Activity.process_textile_content(itsi_activity.safety)
    unless body.empty?
      page, page_element = Activity.add_page_to_section(section, name, body, page_desc)
      section.pages << page
    end
    
    # procedure
    #   name: Procedure
    #   xhtml: proced
    #   open_text_question
    #     proced_text_response
    #   drawing
    #     proced_drawing_response
    
    name = "Procedure"
    page_desc = "What procedures should be performed to get ready for this ITSI Activity?."
    extract_question_prompt = itsi_activity.proced_text_response || itsi_activity.proced_drawing_response
    body, question_prompt = Activity.process_textile_content(itsi_activity.proced, extract_question_prompt)
    unless body.empty? && question_prompt.empty?
      page, page_element = Activity.add_page_to_section(section, name, body, page_desc)
      section.pages << page
      if itsi_activity.proced_text_response
        Activity.add_open_response_to_page(page, question_prompt)
      end
      if itsi_activity.proced_drawing_response
        Activity.add_drawing_response_to_page(page, question_prompt)
      end
    end

    # prediction
    #   name: Prediction
    #   xhtml: predict
    #   open_text_question
    #     prediction_text_response
    #   drawing
    #     prediction_drawing_response
    #   graph
    #     prediction_graph_response
    #     (for probe in first collect data section)

    name = "Prediction"
    page_desc = "Have the learner think about and predict the outcome of an experiment."
    extract_question_prompt = itsi_activity.prediction_text_response || 
      itsi_activity.prediction_drawing_response || itsi_activity.prediction_graph_response
    body, question_prompt = Activity.process_textile_content(itsi_activity.predict, extract_question_prompt)
    unless body.empty? && question_prompt.empty?
      page, page_element = Activity.add_page_to_section(section, name, body, page_desc)
      section.pages << page
      if itsi_activity.prediction_text_response
        Activity.add_open_response_to_page(page, question_prompt)
      end
      if itsi_activity.prediction_drawing_response
        Activity.add_drawing_response_to_page(page, question_prompt)
      end
      if itsi_activity.prediction_graph_response
        Activity.add_prediction_graph_response_to_page(page, question_prompt)
      end
    end
    
    # collectdata
    #   name: Collect Data
    #   xhtml: collectdata
    #   data_collector
    #     collectdata_probe_active
    #     collectdata_probetype_id
    #     collectdata_probe_multi
    #   model
    #     model_id
    #     collectdata_model_active
    #   open_text_question
    #     collectdata_text_response
    #   drawing
    #     collectdata_drawing_response
    #   graph
    #     collectdata_graph_response
    #     (for probe in second collect data section)
    # 
    
    name = "Collect Data"
    page_desc = "The learner conducts experiments using probes and models."
    extract_question_prompt = itsi_activity.collectdata_text_response || 
      itsi_activity.collectdata_drawing_response || itsi_activity.collectdata_graph_response
    body, question_prompt = Activity.process_textile_content(itsi_activity.collectdata, extract_question_prompt)
    unless body.empty? && question_prompt.empty?
      page, page_element = Activity.add_page_to_section(section, name, body, page_desc)
      section.pages << page
      if itsi_activity.collectdata_probe_active
        probe_type = ProbeType.find(itsi_activity.probe_type_id)
        Activity.add_data_collector_to_page(page, probe_type, itsi_activity.collectdata_probe_multi)
      end
      if itsi_activity.collectdata_text_response
        Activity.add_open_response_to_page(page, question_prompt)
      end
      if itsi_activity.collectdata_drawing_response
        Activity.add_drawing_response_to_page(page, question_prompt)
      end
      if itsi_activity.collectdata_graph_response
        Activity.add_prediction_graph_response_to_page(page, question_prompt)
      end
    end
    #   xhtml: collectdata2
    #   data_collector
    #     collectdata2_probe_active
    #     collectdata2_probetype_id
    #     collectdata2_probe_multi
    #     collectdata2_calibration_active
    #     collectdata2_calibration_id
    #   model
    #     collectdata2_model_id
    #     collectdata2_model_active
    #   open_text_question
    #     collectdata2_text_response
    #   drawing
    #     collectdata2_drawing_response
    #

    extract_question_prompt = itsi_activity.collectdata2_text_response || itsi_activity.collectdata2_drawing_response
    body, question_prompt = Activity.process_textile_content(itsi_activity.collectdata2, extract_question_prompt)
    unless body.empty? && question_prompt.empty?
      Activity.add_xhtml_to_page(page, body)
      if itsi_activity.collectdata2_probe_active
        probe_type = ProbeType.find(itsi_activity.probe_type_id)
        Activity.add_data_collector_to_page(page, probe_type, itsi_activity.collectdata2_probe_multi)
      end
      if itsi_activity.collectdata2_text_response
        Activity.add_open_response_to_page(page, question_prompt)
      end
      if itsi_activity.collectdata2_drawing_response
        Activity.add_drawing_response_to_page(page, question_prompt)
      end
    end

    #   xhtml: collectdata3
    #   data_collector
    #     collectdata3_probe_active
    #     collectdata3_probetype_id
    #     collectdata3_probe_multi
    #     collectdata3_calibration_active
    #     collectdata3_calibration_id
    #   model
    #     collectdata3_model_id
    #     collectdata3_model_active
    #   open_text_question
    #     collectdata3_text_response
    #   drawing
    #     collectdata3_drawing_response


    extract_question_prompt = itsi_activity.collectdata3_text_response || itsi_activity.collectdata3_drawing_response
    body, question_prompt = Activity.process_textile_content(itsi_activity.collectdata3, extract_question_prompt)
    unless body.empty? && question_prompt.empty?
      Activity.add_xhtml_to_page(page, body)
      if itsi_activity.collectdata3_probe_active
        probe_type = ProbeType.find(itsi_activity.probe_type_id)
        Activity.add_data_collector_to_page(page, probe_type, itsi_activity.collectdata3_probe_multi)
      end
      if itsi_activity.collectdata3_text_response
        Activity.add_open_response_to_page(page, question_prompt)
      end
      if itsi_activity.collectdata3_drawing_response
        Activity.add_drawing_response_to_page(page, question_prompt)
      end
    end
    
    # analysis
    #   name: Analysis
    #   xhtml: analysis
    #   open_text_question
    #     analysis_text_response
    #   drawing
    #     analysis_drawing_response

    name = "Analysis"
    page_desc = "How can learners reflect and analyze the experiments they just completed?"
    body, question_prompt = Activity.process_textile_content(itsi_activity.analysis)
    unless body.empty?
      page, page_element = Activity.add_page_to_section(section, name, body, page_desc)
      section.pages << page
    end

    # conclusion
    #   name: Conclusion
    #   xhtml: conclusion
    #   open_text_question
    #     conclusion_text_response
    #   drawing
    #     conclusion_drawing_response

    name = "Conclusion"
    page_desc = "What are some reasonable conclusions a learner might come to after this ITSI Activity?"
    body, question_prompt = Activity.process_textile_content(itsi_activity.conclusion)
    unless body.empty?
      page, page_element = Activity.add_page_to_section(section, name, body, page_desc)
      section.pages << page
    end
    
    # further
    #   name: Further Activities
    #   xhtml: further
    #   data_collector
    #     further_probe_active
    #     further_probetype_id
    #     further_probe_multi
    #     furtherprobe_calibration_active
    #     furtherprobe_calibration_id
    #   model
    #     further_model_id
    #     further_model_active
    #   open_text_question
    #     further_text_response
    #   drawing
    #     further_drawing_response

    name = "Further Activities"
    page_desc = "Think about any further activities a learner might want to try."
    extract_question_prompt = itsi_activity.further_text_response || itsi_activity.further_drawing_response
    body, question_prompt = Activity.process_textile_content(itsi_activity.further, extract_question_prompt)
    unless body.empty? && question_prompt.empty?
      page, page_element = Activity.add_page_to_section(section, name, body, page_desc)
      section.pages << page
      if itsi_activity.further_text_response
        Activity.add_open_response_to_page(page, question_prompt)
      end
      if itsi_activity.further_drawing_response
        Activity.add_drawing_response_to_page(page, question_prompt)
      end
    end
    activity
  end

  # def self.create_from_itsi(itsi_activity)
  #   activity = Activity.create do |i|
  #     i.name = itsi_activity.name
  #     i.description = itsi_activity.description
  #   end
  #   unless itsi_activity.introduction.empty?
  #     page_element = Xhtml.create do |x|
  #       x.name = "Introduction"
  #       x.description = ""
  #       x.content = Activity.process_itsi_image_links(RedCloth.new(itsi_activity.introduction).to_html)
  #     end
  #     page = Page.create do |p|
  #       p.name = "Introduction: page 1"
  #       p.description = "An ITSI Introduction normally only has one page."
  #       page_element.pages << p
  #     end
  #     introduction = Section.create do |s|
  #       s.name = "Introduction"
  #       s.description = "An ITSI Introduction is focused on a Discovery Question that drives the Activity."
  #       s.pages << page
  #     end
  #     activity.sections << introduction
  #     activity.save!
  #   end
  #   unless itsi_activity.materials.empty?
  #   page_element = Xhtml.create do |x|
  #     x.name = "Materials"
  #     x.description = ""
  #     x.content = Activity.process_itsi_image_links(RedCloth.new(itsi_activity.introduction).to_html)
  #   end
  #   page = Page.create do |p|
  #     p.name = "Materials: page 1"
  #     p.description = "An ITSI Introduction normally only has one page."
  #     page_element.pages << p
  #   end
  #   introduction = Section.create do |s|
  #     s.name = "Introduction"
  #     s.description = "An ITSI Introduction is focused on a Discovery Question that drives the Activity."
  #     s.pages << page
  #   end
  #   activity = Activity.create do |i|
  #     i.name = itsi_activity.name
  #     i.description = itsi_activity.description
  #     i.sections << section
  #   end
  #   activity
  # end    
    
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
