namespace :rigse do
  namespace :import do
    
    require 'hpricot'
    
    desc "erase and import ITSI activities"
    task :erase_and_import_itsi_activities => :environment do
      raise "need an 'itsi' specification in database.yml to run this task" unless ActiveRecord::Base.configurations['itsi']
      ITSIDIY_URL = ActiveRecord::Base.configurations['itsi']['asset_url']
      Investigation.find(:all, :conditions => "name like 'ITSI%'").each {|i| print 'd'; i.destroy }
      puts
      itsi_user = Itsi::User.find_by_login('itest')
      rites_itsi_import_user = find_or_create_itsi_import_user
      itsi_activities = Itsi::Activity.find_all_by_user_id_and_collectdata_model_active_and_public(itsi_user, false, true)
      itsi_activities.each {|itsi_activity| print '.'; create_investigation_from_itsi(itsi_activity, rites_itsi_import_user) }
    end

    desc "erase and import ITSI Units from indexed from the CCPortal"
    task :erase_and_import_ccp_itsi_units => :environment do
      raise "need an 'itsi' specification in database.yml to run this task" unless ActiveRecord::Base.configurations['itsi']
      raise "need an 'ccportal' specification in database.yml to run this task" unless ActiveRecord::Base.configurations['ccportal']
      ITSIDIY_URL = ActiveRecord::Base.configurations['itsi']['asset_url']
      Investigation.find(:all, :conditions => "name like 'ITSI Unit%'").each {|i| print 'd'; i.destroy }
      puts
      rites_itsi_import_user = find_or_create_itsi_import_user
      ccp_itsi_project = Ccportal::Project.find_by_project_name('ITSI')
      ccp_itsi_project.units.each do |ccp_itsi_unit|
        print '.'
        create_investigation_from_ccp_itsi_unit(ccp_itsi_unit, rites_itsi_import_user)
      end
    end
    
    def find_or_create_itsi_import_user
      unless user = User.find_by_login('rites_itsi_import_user')
        member_role = Role.find_by_title('member')
        user = User.create(:login => 'rites_itsi_import_user', :first_name => 'ITSI', :last_name => 'Importer', :email => 'rites_itsi_import_user@concord.org', :password => "it$iu$er", :password_confirmation => "it$iu$er")
        user.save
        user.register!
        user.activate!
        user.roles << member_role
      end
      user
    end

    def create_investigation_from_ccp_itsi_unit(ccp_itsi_unit, rites_user)
      itsi_prefix = "ITSI Unit: #{ccp_itsi_unit.unit_name}"
      investigation = Investigation.create do |i|
        i.name = itsi_prefix
        i.user = rites_user
        i.description = "An ITSI unit is a collection of ITSI Activities"
      end
      ccp_itsi_unit.activities.each do |ccp_itsi_activity|
        primary_key = ccp_itsi_activity.diy_identifier
        if !primary_key.empty? && itsi_activity = Itsi::Activity.find(primary_key)
          add_itsi_activity_to_investigation(investigation, itsi_activity, rites_user)
          print "-#{primary_key}-"
        else
          print "-x-"
        end
      end
    end

    def create_investigation_from_itsi_activity(itsi_activity, rites_user)
      itsi_prefix = "ITSI: #{itsi_activity.id} - #{itsi_activity.name}"
      investigation = Investigation.create do |i|
        i.name = itsi_prefix
        i.user = rites_user
        i.description = itsi_activity.description
      end
      add_itsi_activity_to_investigation(investigation, itsi_activity, rites_user)
    end
    
    def add_itsi_activity_to_investigation(investigation, itsi_activity, rites_user)
      itsi_prefix = "ITSI: #{itsi_activity.id} - #{itsi_activity.name}"
      activity = Activity.create do |i|
        i.name = itsi_prefix
        i.user = rites_user
        i.description = itsi_activity.description
      end
      investigation.activities << activity

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
      body, question_prompt = process_textile_content(itsi_activity.introduction, extract_question_prompt)
      unless body.empty? && question_prompt.empty?
        section = add_section_to_activity(activity, name, page_desc)
        page, page_element = add_page_to_section(section, name, body, page_desc)
        section.pages << page
        if itsi_activity.introduction_text_response
          add_open_response_to_page(page, question_prompt)
        end
        if itsi_activity.introduction_drawing_response
          add_drawing_response_to_page(page, question_prompt)
        end
      end

      # standards
      #   name: Standards
      #   xhtml: standards

      name = "Standards"
      page_desc = "What standards does this ITSI Activity cover?"
      body, question_prompt = process_textile_content(itsi_activity.standards)
      unless body.empty?
        section = add_section_to_activity(activity, name, page_desc)
        page, page_element = add_page_to_section(section, name, body, page_desc)
        section.pages << page
      end

      # materials
      #   name: Materials
      #   xhtml: materials

      name = "Materials"
      page_desc = "What materials does this ITSI Activity require?"
      body, question_prompt = process_textile_content(itsi_activity.materials)
      unless body.empty?
        section = add_section_to_activity(activity, name, page_desc)
        page, page_element = add_page_to_section(section, name, body, page_desc)
        section.pages << page
      end

      # safety
      #   name: Safety
      #   xhtml: safety

      name = "Safety"
      page_desc = "Are there any safety considerations to be aware of in this ITSI Activity?"
      body, question_prompt = process_textile_content(itsi_activity.safety)
      unless body.empty?
        section = add_section_to_activity(activity, name, page_desc)
        page, page_element = add_page_to_section(section, name, body, page_desc)
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
      body, question_prompt = process_textile_content(itsi_activity.proced, extract_question_prompt)
      unless body.empty? && question_prompt.empty?
        section = add_section_to_activity(activity, name, page_desc)
        page, page_element = add_page_to_section(section, name, body, page_desc)
        section.pages << page
        if itsi_activity.proced_text_response
          add_open_response_to_page(page, question_prompt)
        end
        if itsi_activity.proced_drawing_response
          add_drawing_response_to_page(page, question_prompt)
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
      body, question_prompt = process_textile_content(itsi_activity.predict, extract_question_prompt)
      unless body.empty? && question_prompt.empty?
        section = add_section_to_activity(activity, name, page_desc)
        page, page_element = add_page_to_section(section, name, body, page_desc)
        section.pages << page
        if itsi_activity.prediction_text_response
          add_open_response_to_page(page, question_prompt)
        end
        if itsi_activity.prediction_drawing_response
          add_drawing_response_to_page(page, question_prompt)
        end
        if itsi_activity.prediction_graph_response
          add_prediction_graph_response_to_page(page, question_prompt)
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
      body, question_prompt = process_textile_content(itsi_activity.collectdata, extract_question_prompt)
      unless body.empty? && question_prompt.empty?
        section = add_section_to_activity(activity, name, page_desc)
        page, page_element = add_page_to_section(section, name, body, page_desc)
        section.pages << page
        if itsi_activity.collectdata_probe_active
          probe_type = ProbeType.find(itsi_activity.probe_type_id)
          add_data_collector_to_page(page, probe_type, itsi_activity.collectdata_probe_multi)
        end
        if itsi_activity.collectdata_model_active
          model = itsi_activity.model
          if model.model_type.name == "Molecular Workbench"
            add_mw_model_to_page(page, model)
          end
        end
        if itsi_activity.collectdata_text_response
          add_open_response_to_page(page, question_prompt)
        end
        if itsi_activity.collectdata_drawing_response
          add_drawing_response_to_page(page, question_prompt)
        end
        if itsi_activity.collectdata_graph_response
          add_prediction_graph_response_to_page(page, question_prompt)
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
      body, question_prompt = process_textile_content(itsi_activity.collectdata2, extract_question_prompt)
      unless body.empty? && question_prompt.empty?
        add_xhtml_to_page(page, body)
        if itsi_activity.collectdata2_probe_active
          probe_type = ProbeType.find(itsi_activity.probe_type_id)
          add_data_collector_to_page(page, probe_type, itsi_activity.collectdata2_probe_multi)
        end
        if itsi_activity.collectdata2_model_active
          model = itsi_activity.second_model
          if model.model_type.name == "Molecular Workbench"
            add_mw_model_to_page(page, model)
          end
        end
        if itsi_activity.collectdata2_text_response
          add_open_response_to_page(page, question_prompt)
        end
        if itsi_activity.collectdata2_drawing_response
          add_drawing_response_to_page(page, question_prompt)
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
      body, question_prompt = process_textile_content(itsi_activity.collectdata3, extract_question_prompt)
      unless body.empty? && question_prompt.empty?
        add_xhtml_to_page(page, body)
        if itsi_activity.collectdata3_probe_active
          probe_type = ProbeType.find(itsi_activity.probe_type_id)
          add_data_collector_to_page(page, probe_type, itsi_activity.collectdata3_probe_multi)
        end
        if itsi_activity.collectdata3_model_active
          model = itsi_activity.third_model
          if model.model_type.name == "Molecular Workbench"
            add_mw_model_to_page(page, model)
          end
        end
        if itsi_activity.collectdata3_text_response
          add_open_response_to_page(page, question_prompt)
        end
        if itsi_activity.collectdata3_drawing_response
          add_drawing_response_to_page(page, question_prompt)
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
      body, question_prompt = process_textile_content(itsi_activity.analysis)
      unless body.empty?
        section = add_section_to_activity(activity, name, page_desc)
        page, page_element = add_page_to_section(section, name, body, page_desc)
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
      body, question_prompt = process_textile_content(itsi_activity.conclusion)
      unless body.empty?
        section = add_section_to_activity(activity, name, page_desc)
        page, page_element = add_page_to_section(section, name, body, page_desc)
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
      body, question_prompt = process_textile_content(itsi_activity.further, extract_question_prompt)
      unless body.empty? && question_prompt.empty?
        section = add_section_to_activity(activity, name, page_desc)
        page, page_element = add_page_to_section(section, name, body, page_desc)
        section.pages << page
        if itsi_activity.further_probe_active
          probe_type = ProbeType.find(itsi_activity.further_probetype_id)
          add_data_collector_to_page(page, probe_type, itsi_activity.further_probe_multi)
        end
        if itsi_activity.further_model_active
          model = itsi_activity.fourth_model
          if model.model_type.name == "Molecular Workbench"
            add_mw_model_to_page(page, model)
          end
        end
        if itsi_activity.further_text_response
          add_open_response_to_page(page, question_prompt)
        end
        if itsi_activity.further_drawing_response
          add_drawing_response_to_page(page, question_prompt)
        end
      end
      investigation
    end
    
    def process_textile_content(textile_content, split_last_paragraph=false)
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

    def create_section_page(name, html_content='', section_description='', page_description='')
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

    def add_page_to_section(section, name, html_content='', page_description='')
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

    def add_mw_model_to_page(page, model)
      page_element = MwModelerPage.create do |mw|
        mw.name = model.name
        mw.description = model.description
        mw.authored_data_url = model.url
      end
      page_element.pages << page
    end
    
    def add_open_response_to_page(page, question_prompt)
      page_element = OpenResponse.create do |o|
        o.name = page.name + ": Open Response Question"
        o.description = ""
        o.prompt = question_prompt
      end
      page_element.pages << page
    end

    def add_prediction_graph_response_to_page(page, question_prompt)
      page_element = DataCollector.create do |d|
        d.name = page.name + ": Prediction Graph Question"
        d.title = d.name
        d.description = "Still to be implemented: this should be converted into a real Prediction Graph response."
      end
      page_element.pages << page
    end

    def add_drawing_response_to_page(page, question_prompt)
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

    def add_xhtml_to_page(page, html_content)
      page_element = Xhtml.create do |x|
        x.name = page.name + ": Body Content (html)"
        x.description = ""
        x.content = html_content
      end
    end

    def add_data_collector_to_page(page, probe_type, multiple_graphs)
      page_element = DataCollector.create do |d|
        d.name = page.name + ": #{probe_type.name} Data Collector"
        d.title = d.name
        d.probe_type = probe_type
        d.multiple_graphable_enabled = multiple_graphs
        d.description = "This a Data Collector Graph that will collect data from a #{probe_type.name} sensor."
      end
      page_element.pages << page
    end

    def add_section_to_activity(activity, section_name, section_desc)
      section = Section.create do |s|
        s.name = section_name
        s.description = section_desc
      end
      activity.sections << section
      section
    end
    
  end
end


