class ItsiImporter
  @@attributes = nil
  ACTIVITY_TEMPLATE_UUID = "7d7f511d-45c6-4002-a5d8-6d6d63a7f12d"
  SECTIONS_MAP = [
    { :key => :introduction,
      :name => "Introduction",
      :page_desc => "ITSI Activities start with a Discovery Question.",
      :extra_elements => [:text_response, :draw_response]
    },
    { :key => :standards,
      :name => "Standards",
      :page_desc => "What standards does this ITSI Activity cover?",
      :extra_elements => []
    },
    { :key => :career_stem,
      :name => "Career STEM Question",
      :page_desc => "Career STEM Question",
      :extra_elements => [:text_response]
    },
    { :key => :materials,
      :name => "Materials",
      :page_desc => "What materials does this ITSI Activity require?",
      :extra_elements => []
    },
    { :key => :safety,
      :name => "Safety",
      :page_desc => "Are there any safety considerations to be aware of in this ITSI Activity?",
      :extra_elements => []
    },
    { :key => :proced,
      :name => "Procedure",
      :page_desc => "What procedures should be performed to get ready for this ITSI Activity?.",
      :extra_elements => [:text_response, :draw_response]
    },
    { :key => :predict,
      :name => "Prediction",
      :page_desc => "Have the learner think about and predict the outcome of an experiment.",
      :extra_elements => [:text_response, :draw_response, :prediction_response]
    },
    { :key => :collectdata,
      :name => "Collect Data",
      :page_desc => "The learner conducts experiments using probes and models.",
      :extra_elements => [:probe, :model, :text_response, :draw_response, :prediction_response]
    },
    { :key => :collectdata2,
      :name => "Collect Data",
      :page_desc => "The learner conducts experiments using probes and models.",
      :extra_elements => [:probe, :model, :text_response, :draw_response]
    },
    { :key => :collectdata3,
      :name => "Collect Data",
      :page_desc => "The learner conducts experiments using probes and models.",
      :extra_elements => [:probe, :model, :text_response, :draw_response]
    },
    { :key => :analysis,
      :name => "Analysis",
      :page_desc => "How can learners reflect and analyze the experiments they just completed?",
      :extra_elements => [:text_response, :draw_response]
    },
    { :key => :conclusion,
      :name => "Conclusion",
      :page_desc => "What are some reasonable conclusions a learner might come to after this ITSI Activity?",
      :extra_elements => [:text_response, :draw_response]
    },
    { :key => :career_stem2,
      :name => "Second Career STEM Question",
      :page_desc => "Second Career STEM Question",
      :extra_elements => [:text_response]
    },
    { :key => :further,
      :name => "Further Activities",
      :page_desc => "Think about any further activities a learner might want to try.",
      :extra_elements => [:probe, :model, :text_response, :draw_response]
    }
  ]

  class <<self

    def find_or_create_itsi_import_user
      unless user = User.find_by_login('itsi_import_user')
        member_role = Role.find_by_title('member')
        user = User.create(:login => 'itsi_import_user', :first_name => 'ITSI', :last_name => 'Importer', :email => 'itsi_import_user@concord.org', :password => "it$iu$er", :password_confirmation => "it$iu$er")
        user.save
        user.register!
        user.activate!
        user.roles << member_role
      end
      user
    end

    def find_or_create_itsi_activity_template
      act = Activity.find_by_uuid(ACTIVITY_TEMPLATE_UUID)
      puts "ITSI Template - Activity #{act.id}" if act
      return act if act

      act = Activity.create!(:name => "Single-page Activity Template", :user => ItsiImporter.find_or_create_itsi_import_user, :is_template => true ) {|a| a.uuid = ACTIVITY_TEMPLATE_UUID}
      SECTIONS_MAP.each do |section_def|
        section = Section.create!(:name => section_def[:name], :description => section_def[:name], :activity => act, :user => act.user)
        page = Page.create!(:name => section_def[:name], :description => section_def[:page_desc], :section => section, :user => act.user)

        components = [:main_content] + section_def[:extra_elements]
        components.each do |elem|
          page_elem = nil
          case elem
            when :main_content
              page_elem = Embeddable::Diy::Section.create!(:name => section_def[:name], :content => section_def[:page_desc], :has_question => false, :user => act.user)
            when :probe
              probe_type = Probe::ProbeType.default
              prototype_data_collector = Embeddable::DataCollector.get_prototype({:probe_type => probe_type, :calibration => nil, :graph_type => 'Sensor'})
              page_elem = Embeddable::Diy::Sensor.create!(:prototype => prototype_data_collector, :user => act.user)
            when :model
              # TODO: If there is no Diy::Model.first, we need to make one.
              model = Diy::Model.first
              page_elem = Embeddable::Diy::EmbeddedModel.create!(:diy_model => model, :user => act.user)
            when :text_response
              # Is handled by has_question attribute of main_content?
            when :draw_response
              page_elem = Embeddable::DrawingTool.create(:name => "drawing response", :description => "drawing response", :user => act.user)
            when :prediction_response
              probe_type = Probe::ProbeType.default
              prototype_prediction = Embeddable::DataCollector.get_prototype({:probe_type => probe_type, :graph_type => 'Prediction'})
              page_elem = Embeddable::Diy::Sensor.create!(:prototype => prototype_prediction, :user => act.user)
          end
          if ! page_elem.nil?
            page_elem.pages << page
            page_elem.disable
          end
        end
      end
      puts "ITSI Template - Activity #{act.id}"
      return act
    end

    def create_activities_from_ccp_itsi_unit(ccp_itsi_unit, prefix="")
      # Carolyn and Ed wanted this the prefix removed for the itsi-su importer
      name = "#{prefix} #{ccp_itsi_unit.unit_name}".strip
      puts "creating: #{name}: "
      ccp_itsi_unit.activities.each do |ccp_itsi_activity|
        foreign_key = ccp_itsi_activity.diy_identifier
        begin
          unless foreign_key.empty?
            itsi_activity = Itsi::Activity.find(foreign_key)
            activity = create_activity_from_itsi_activity(itsi_activity, nil, prefix) # nil user will import the DIY user and associate the activity with that user
            activity.unit_list = ccp_itsi_unit.unit_name
            activity.grade_level_list = ccp_itsi_activity.level.level_name
            activity.subject_area_list = ccp_itsi_activity.subject.subject_name
            activity.publish! unless activity.published?
            activity.save
            puts "  ITSI: #{itsi_activity.id} - #{itsi_activity.name}"
          else
            puts "  -- foreign key empty for ITSI Activity --"
          end
        rescue ActiveRecord::RecordNotFound
          puts "  -- itsi activity id: #{itsi_activity.id} not found --"
        end
      end
      puts
    end

    def create_investigation_from_ccp_itsi_unit(ccp_itsi_unit, user, prefix="")
      # Carolyn and Ed wanted this the prefix removed for the itsi-su importer
      name = "#{prefix} #{ccp_itsi_unit.unit_name}".strip
      puts "creating: #{name}: "
      investigation = Investigation.create do |i|
        i.name = name
        i.user = user
        i.description = "An ITSI unit is a collection of ITSI Activities"
      end
      ccp_itsi_unit.activities.each do |ccp_itsi_activity|
        foreign_key = ccp_itsi_activity.diy_identifier
        begin
          unless foreign_key.empty?
            itsi_activity = Itsi::Activity.find(foreign_key)
            ItsiImporter.add_itsi_activity_to_investigation(investigation, itsi_activity, user,prefix)
            puts "  ITSI: #{itsi_activity.id} - #{itsi_activity.name}"
          else
            puts "  -- foreign key empty for ITSI Activity --"
          end
        rescue ActiveRecord::RecordNotFound
          puts "  -- itsi activity id: #{itsi_activity.id} not found --"
        end
      end
      puts
    end

    def create_investigation_from_itsi_activity(itsi_activity, user,  prefix="")
      # itsi_prefix = "ITSI: #{itsi_activity.id} - #{itsi_activity.name}"
      name = "#{prefix} #{itsi_activity.name} (#{itsi_activity.id})".strip
      puts "creating: #{name}: "
      investigation = Investigation.create do |i|
        i.name = name
        i.user = user
        i.description = itsi_activity.description
      end
      ItsiImporter.add_itsi_activity_to_investigation(investigation, itsi_activity, user, prefix)
    end

    def add_itsi_activity_to_investigation(investigation, itsi_activity, user, prefix="")
      investigation.activities << create_activity_from_itsi_activity(itsi_activity, user, prefix="")
      investigation
    end

    def create_activity_from_itsi_activity_old(itsi_activity, user, prefix="")
       @@prediction_graph = nil
        if itsi_activity.collectdata_probe_active
          @@first_probe_type = Probe::ProbeType.find(itsi_activity.probe_type_id)
        else
          @@first_probe_type = Probe::ProbeType.find_by_name('Temperature')
          @@first_probe_type.name = "Temperature as default for missing probe_type_id: #{itsi_activity.probe_type_id}"
        end
        # itsi_prefix = "ITSI: #{itsi_activity.id} - #{itsi_activity.name}"
        name = "#{prefix} #{itsi_activity.name} (#{itsi_activity.id})".strip
        activity = Activity.create do |i|
          i.name = name
          i.user = user
          i.description = itsi_activity.description
        end

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
        body, question_prompt = ItsiImporter.process_textile_content(itsi_activity.introduction, extract_question_prompt)
        unless body.empty? && question_prompt.empty?
          section = ItsiImporter.add_section_to_activity(activity, name, page_desc)
          page, page_element = ItsiImporter.add_page_to_section(section, name, body, page_desc)
          if itsi_activity.introduction_text_response
            ItsiImporter.add_open_response_to_page(page, question_prompt)
          end
          if itsi_activity.introduction_drawing_response
            ItsiImporter.add_drawing_response_to_page(page, question_prompt)
          end
        end

        # standards
        #   name: Standards
        #   xhtml: standards

        name = "Standards"
        page_desc = "What standards does this ITSI Activity cover?"
        body, question_prompt = ItsiImporter.process_textile_content(itsi_activity.standards)
        unless body.empty?
          section = ItsiImporter.add_section_to_activity(activity, name, page_desc)
          page, page_element = ItsiImporter.add_page_to_section(section, name, body, page_desc)
        end

        # materials
        #   name: Materials
        #   xhtml: materials

        name = "Materials"
        page_desc = "What materials does this ITSI Activity require?"
        body, question_prompt = ItsiImporter.process_textile_content(itsi_activity.materials)
        unless body.empty?
          section = ItsiImporter.add_section_to_activity(activity, name, page_desc)
          page, page_element = ItsiImporter.add_page_to_section(section, name, body, page_desc)
        end

        # safety
        #   name: Safety
        #   xhtml: safety

        name = "Safety"
        page_desc = "Are there any safety considerations to be aware of in this ITSI Activity?"
        body, question_prompt = ItsiImporter.process_textile_content(itsi_activity.safety)
        unless body.empty?
          section = ItsiImporter.add_section_to_activity(activity, name, page_desc)
          page, page_element = ItsiImporter.add_page_to_section(section, name, body, page_desc)
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
        body, question_prompt = ItsiImporter.process_textile_content(itsi_activity.proced, extract_question_prompt)
        unless body.empty? && question_prompt.empty?
          section = ItsiImporter.add_section_to_activity(activity, name, page_desc)
          page, page_element = ItsiImporter.add_page_to_section(section, name, body, page_desc)
          if itsi_activity.proced_text_response
            ItsiImporter.add_open_response_to_page(page, question_prompt)
          end
          if itsi_activity.proced_drawing_response
            ItsiImporter.add_drawing_response_to_page(page, question_prompt)
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
        body, question_prompt = ItsiImporter.process_textile_content(itsi_activity.predict, extract_question_prompt)
        unless body.empty? && question_prompt.empty?
          section = ItsiImporter.add_section_to_activity(activity, name, page_desc)
          page, page_element = ItsiImporter.add_page_to_section(section, name, body, page_desc)
          if itsi_activity.prediction_text_response
            ItsiImporter.add_open_response_to_page(page, question_prompt)
          end
          if itsi_activity.prediction_drawing_response
            ItsiImporter.add_drawing_response_to_page(page, question_prompt)
          end
          if itsi_activity.prediction_graph_response
            ItsiImporter.add_prediction_graph_response_to_page(page, question_prompt)
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
        body, question_prompt = ItsiImporter.process_textile_content(itsi_activity.collectdata, extract_question_prompt)
        unless body.empty? && question_prompt.empty?
          section = ItsiImporter.add_section_to_activity(activity, name, page_desc)
          page, page_element = ItsiImporter.add_page_to_section(section, name, body, page_desc)
          if itsi_activity.collectdata_probe_active
            probe_type = Probe::ProbeType.find(itsi_activity.probe_type_id)
            ItsiImporter.add_data_collector_to_page(page, probe_type, itsi_activity.collectdata_probe_multi)
          end
          if itsi_activity.collectdata_model_active
            add_model_to_page(page, itsi_activity.model)
          end
          if itsi_activity.collectdata_text_response
            ItsiImporter.add_open_response_to_page(page, question_prompt)
          end
          if itsi_activity.collectdata_drawing_response
            ItsiImporter.add_drawing_response_to_page(page, question_prompt)
          end
          # if itsi_activity.collectdata_graph_response
          #   ItsiImporter.add_prediction_graph_response_to_page(page, question_prompt)
          # end
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
        body, question_prompt = ItsiImporter.process_textile_content(itsi_activity.collectdata2, extract_question_prompt)
        unless body.empty? && question_prompt.empty?
          ItsiImporter.add_xhtml_to_page(page, body)
          if itsi_activity.collectdata2_probe_active
            probe_type = Probe::ProbeType.find(itsi_activity.probe_type_id)
            ItsiImporter.add_data_collector_to_page(page, probe_type, itsi_activity.collectdata2_probe_multi)
          end
          if itsi_activity.collectdata2_model_active
            model = itsi_activity.second_model
            if model.model_type.name == "Molecular Workbench"
              ItsiImporter.add_mw_model_to_page(page, model)
            end
          end
          if itsi_activity.collectdata2_text_response
            ItsiImporter.add_open_response_to_page(page, question_prompt)
          end
          if itsi_activity.collectdata2_drawing_response
            ItsiImporter.add_drawing_response_to_page(page, question_prompt)
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
        body, question_prompt = ItsiImporter.process_textile_content(itsi_activity.collectdata3, extract_question_prompt)
        unless body.empty? && question_prompt.empty?
          ItsiImporter.add_xhtml_to_page(page, body)
          if itsi_activity.collectdata3_probe_active
            probe_type = Probe::ProbeType.find(itsi_activity.probe_type_id)
            ItsiImporter.add_data_collector_to_page(page, probe_type, itsi_activity.collectdata3_probe_multi)
          end
          if itsi_activity.collectdata3_model_active
            model = itsi_activity.third_model
            if model.model_type.name == "Molecular Workbench"
              ItsiImporter.add_mw_model_to_page(page, model)
            end
          end
          if itsi_activity.collectdata3_text_response
            ItsiImporter.add_open_response_to_page(page, question_prompt)
          end
          if itsi_activity.collectdata3_drawing_response
            ItsiImporter.add_drawing_response_to_page(page, question_prompt)
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
        body, question_prompt = ItsiImporter.process_textile_content(itsi_activity.analysis)
        unless body.empty?
          section = ItsiImporter.add_section_to_activity(activity, name, page_desc)
          page, page_element = ItsiImporter.add_page_to_section(section, name, body, page_desc)
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
        body, question_prompt = ItsiImporter.process_textile_content(itsi_activity.conclusion)
        unless body.empty?
          section = ItsiImporter.add_section_to_activity(activity, name, page_desc)
          page, page_element = ItsiImporter.add_page_to_section(section, name, body, page_desc)
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
        body, question_prompt = ItsiImporter.process_textile_content(itsi_activity.further, extract_question_prompt)
        unless body.empty? && question_prompt.empty?
          section = ItsiImporter.add_section_to_activity(activity, name, page_desc)
          page, page_element = ItsiImporter.add_page_to_section(section, name, body, page_desc)
          if itsi_activity.further_probe_active
            probe_type = Probe::ProbeType.find(itsi_activity.further_probetype_id)
            ItsiImporter.add_data_collector_to_page(page, probe_type, itsi_activity.further_probe_multi)
          end
          if itsi_activity.further_model_active
            model = itsi_activity.fourth_model
            if model.model_type.name == "Molecular Workbench"
              ItsiImporter.add_mw_model_to_page(page, model)
            end
          end
          if itsi_activity.further_text_response
            ItsiImporter.add_open_response_to_page(page, question_prompt)
          end
          if itsi_activity.further_drawing_response
            ItsiImporter.add_drawing_response_to_page(page, question_prompt)
          end
        end
        activity
    end

    ##
    ## NP: new definition of create_activity_from_itsi_activity
    ## TODO: Add itsi user

    def create_activity_from_itsi_activity(itsi_activity, user=nil, prefix="", use_number=false)
      prefix = "" if prefix.nil?
      prefix << " " if prefix.size > 0
      name = "#{prefix}#{itsi_activity.name}".strip
      if use_number
        name = "#{name} (#{itsi_activity.id})"
      end
      user = find_or_import_itsi_user(itsi_activity.user) unless user
      activity = Activity.find_by_uuid(itsi_activity.uuid)
      unless activity
        activity = Activity.create do |i|
          i.name = name
          i.user = user
          i.description = itsi_activity.description
          i.uuid = itsi_activity.uuid
          i.publish if itsi_activity.public
        end

        SECTIONS_MAP.each do |section|
          process_diy_activity_section(activity,itsi_activity,section[:key],section[:name],section[:page_desc])
        end
      end
      return activity
    end

    def find_or_import_itsi_user(diy_user)
      user = User.find_by_uuid(diy_user.uuid)
      user = User.find_by_login(diy_user.login) unless user
      unless user
        ccp_user = Ccportal::Member.find_by_diy_member_id(diy_user.id)
        attrs = {
          :login => diy_user.login,
          :first_name => diy_user.first_name,
          :last_name => diy_user.last_name,
          :email => diy_user.email =~ /^no-email/ ? (diy_user.email + "@concord.org") : diy_user.email,
          :vendor_interface_id => diy_user.vendor_interface_id,  ## FIXME: Do these map 1:1 with the DIY?
        }

        user = User.new(attrs)
        user.skip_notifications = true
        if (ccp_user)
          user.password = user.password_confirmation = ccp_user.member_password_ue
        else
          ## Because of the difference in how the DIY creates the password hash and how we create the hash, this password won't work
          user.crypted_password = diy_user.crypted_password
          user.salt = diy_user.salt
        end
        user.save(false)
        user.uuid = diy_user.uuid
        user.save
        user.reload
        c = 0
        begin
          user.register!
          user.activate!
        rescue AASM::InvalidTransition
          c += 1
          retry unless c > 2
        end
        user.roles << Role.find_by_title('member')
        user.roles << Role.find_by_title('author')
      end
      return user
    end

    def attributes
      return @@attributes if @@attributes
      # this is the "standard" form, for which there are exceptions
      #t.boolean "collectdata2_text_response"
      #t.boolean "collectdata2_probe_active"
      #t.boolean "collectdata2_model_active"
      #t.integer "collectdata2_probetype_id"
      #t.integer "collectdata2_model_id"
      #t.boolean "collectdata2_probe_multi"
      #t.boolean "collectdata2_drawing_response"
      #t.boolean "collectdata2_calibration_active"
      #t.integer "collectdata2_calibration_id"
      @@attributes =  %w[
        text_response
        drawing_response
        model_active
        model_id
        probe_active
        probetype_id
        probe_multi
        calibration_active
        calibration_id].map { |e| e.to_sym }
      return @@attributes
    end

    def attribute_name_for(section_key, attribute_name)
      # see initializers/00_core_extensions.rb for the array modification to_hash_keys
      attribs = self.attributes.to_hash_keys { |k| "#{section_key}_#{k.to_s}".to_sym }
      # There are some exceptions for these naming conventions:
      case section_key
      when :predict
        attribs[:graph_response] = :prediction_graph_response
        attribs[:text_response] = :prediction_text_response
        attribs[:drawing_response] = :prediction_drawing_response
      when :collectdata
        attribs[:probetype_id] = :probe_type_id
        attribs[:model_id] = :model_id
        attribs[:calibration_active] = :collectdata1_calibration_active
        attribs[:calibration_id] = :collectdata1_calibration_id
        attribs[:graph_response] = :collectdata_graph_response
      when :further
        attribs[:calibration_active] = :furtherprobe_calibration_active
        attribs[:calibration_id] = :furtherprobe_calibration_id
      end
      return attribs[attribute_name]
    end

    ##
    ## NP: Import a section from the activity (NEW)
    ##
    def process_diy_activity_section(activity,diy_act,section_key,section_name,section_description)
      user = activity.user
      section = Section.create(
        :name => section_name,
        :description => section_description,
        :activity => activity,
        :user => user)
      page = Page.create(
        :name => section_name,
        :description => section_description,
        :section => section,
        :user => user)
      activity.sections << section

      # main text content for section
      orig_content = diy_act.send(section_key.to_sym)
      content,prompt = process_textile_content(orig_content,false)
      main_content = Embeddable::Diy::Section.create(
          :name => section_name,
          :content => content,
          :has_question => (diy_act.respond_to? attribute_name_for(section_key,:text_response)) && diy_act.send(attribute_name_for(section_key,:text_response)),
          :user => user)
      main_content.pages << page
      if (orig_content.nil? || orig_content.empty? || content.nil? || content.empty?)
        main_content.disable
      else
        main_content.enable
      end

      # drawing response
      if (attribute_name_for(section_key,:drawing_response) && (diy_act.respond_to? attribute_name_for(section_key,:drawing_response)))
        drawing_response = Embeddable::DrawingTool.create(
          :name => "drawing response",
          :description => "drawing response",
          :user => user)
        drawing_response.pages << page
        if diy_act.send(attribute_name_for(section_key,:drawing_response))
          drawing_response.enable
        else
          drawing_response.disable
        end
      end

      # model
      if (attribute_name_for(section_key,:model_active) && (diy_act.respond_to? attribute_name_for(section_key,:model_active)))
        model = Diy::Model.first
        model_id = diy_act.send(attribute_name_for(section_key,:model_id))

        if (model_id && model_id > 0)
          begin 
            diy_model = Itsi::Model.find(model_id)
            if diy_model
              model = Diy::Model.from_external_portal(diy_model)
            end
          rescue => e
            puts "#{e}. activity => #{diy_act.name} #{diy_act.id}"
          end
        end

        em_model = Embeddable::Diy::EmbeddedModel.create(:diy_model => model, :user => user)
        em_model.pages << page
        if diy_act.send(attribute_name_for(section_key,:model_active))
          em_model.enable
        else
          em_model.disable
        end
      end

      # probe / sensor
      if (attribute_name_for(section_key,:probetype_id) && (diy_act.respond_to? attribute_name_for(section_key,:probetype_id)))
        probe_type_id = diy_act.send(attribute_name_for(section_key,:probetype_id))
        probe_type = Probe::ProbeType.default
        if probe_type_id != nil
          begin
            probe_type = Probe::ProbeType.find(probe_type_id)
          rescue ActiveRecord::RecordNotFound => e
            puts "#{e}. activity => #{diy_act.name} (#{diy_act.id})"
          end
        end
        calibration = nil
        if probe_type
          # see if we have a calibration to work with:
          if diy_act.send(attribute_name_for(section_key,:calibration_active))
            calibration_id = diy_act.send(attribute_name_for(section_key,:calibration_id))
            calibration = Probe::Calibration.find(calibration_id) if calibration_id
          end
        end

        prototype_data_collector = Embeddable::DataCollector.get_prototype({:probe_type => probe_type, :calibration => calibration, :graph_type => 'Sensor'})
        em_sensor = Embeddable::Diy::Sensor.create(:prototype => prototype_data_collector, :user => user)
        em_sensor.pages << page
        if diy_act.send(attribute_name_for(section_key,:probe_active))
          em_sensor.enable
        else
          em_sensor.disable
        end
      end

      ## embed a prediction graph
      if (attribute_name_for(section_key,:graph_response) && (diy_act.respond_to? attribute_name_for(section_key,:graph_response)))
        next_skey = next_section_key(section_key)
        if (attribute_name_for(next_skey,:probetype_id) && (diy_act.respond_to? attribute_name_for(next_skey,:probetype_id)))
          probe_type_id = diy_act.send(attribute_name_for(next_skey,:probetype_id))
          probe_type = Probe::ProbeType.default
          if probe_type_id != nil
            begin
              probe_type = Probe::ProbeType.find(probe_type_id)
            rescue ActiveRecord::RecordNotFound => e
              puts "#{e}. activity => #{diy_act.name} (#{diy_act.id})"
            end
          end

          prototype_prediction = Embeddable::DataCollector.get_prototype({:probe_type => probe_type, :graph_type => 'Prediction'})
          em_predict = Embeddable::Diy::Sensor.create(:prototype => prototype_prediction, :user => user)
          em_predict.pages << page
          if diy_act.send(attribute_name_for(section_key,:graph_response))
            em_predict.enable
          else
            em_predict.disable
          end
        end
      end
    end

    def next_section_key(section_key)
      next_one = false
      SECTIONS_MAP.each_with_index do |s,i|
        if next_one
          return s[:key]
        end
        if s[:key] == section_key
          next_one = true
        end
      end
    end

    def process_textile_content(textile_content, split_last_paragraph=false)
      return ['',''] if textile_content.nil? || textile_content.empty?
      doc = Hpricot(RedCloth.new(textile_content).to_html)
      # if imaages use paths relative to the itsidiy make the full
      (doc/"img[@src]").each do |img|
        img[:src] = ITSI_ASSET_URL.merge(img[:src]).to_s
      end
      # if split_last_paragraph is true then split the content at the
      # last paragraph and return the last paragraph in the second element
      if split_last_paragraph
        last_paragraph = (doc/"p:last-of-type").remove.to_html
        body = doc.to_html
        return [body, last_paragraph]
      else
        return [doc.to_html, '']
      end
    end

    def create_section_page(name, html_content='', section_description='', page_description='')
      page = Page.create do |p|
        p.name = "#{name}s"
        p.description = page_description
      end
      embeddable = Embeddable::Xhtml.create do |x|
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
          # For ITSI_SU Ed Hazzard says he doesn't want page names to be added....
          # p.name = "#{name}"
          p.description = page_description
        end
        page_embeddable = nil
      else
        page_embeddable = Embeddable::Xhtml.create do |x|
          # For ITSI_SU Ed Hazzard says he doesn't want page names or descriptions being added to text content
          # x.name = name + ": Body Content (html)"
          x.description = ""
          # look for weird entity that should actually be an endash -- what causes this??
          # cant figure out right now the relations between textile / html and escape entities.
          html_content.gsub!(/â€“/,"—")
          # we are also seeing things like this: &#8217;  =- &amp;#8217; -- double encoded?
          html_content.gsub!(/&amp;#(\d+);/, '&#\1;')
          x.content = html_content
        end
        page = Page.create do |p|
          # For ITSI_SU Ed Hazzard says he doesn't want page names to be added....
          # p.name = "#{name}"
          p.description = page_description
          page_embeddable.pages << p
        end
      end
      section.pages << page
      [page, page_embeddable]
    end

    def add_model_to_page(page, model)
      case model.model_type.name
      when "Molecular Workbench"
        ItsiImporter.add_mw_model_to_page(page, model)
      when "NetLogo"
        ItsiImporter.add_nl_model_to_page(page, model)
      else
        add_xhtml_to_page(page, "unsupported model type: #{model.model_type.name}")
      end
    end

    def add_mw_model_to_page(page, model)
      page_embeddable = Embeddable::MwModelerPage.create do |mw|
        mw.name = model.name
        mw.description = model.description
        mw.authored_data_url = model.url
      end
      page_embeddable.pages << page
    end

    def add_nl_model_to_page(page, model)
      page_embeddable = Embeddable::NLogoModel.create do |mw|
        mw.name = model.name
        mw.description = model.description
        mw.authored_data_url = model.url
      end
      page_embeddable.pages << page
    end

    def add_open_response_to_page(page, question_prompt)
      page_embeddable = Embeddable::OpenResponse.create do |o|
        o.name = page.name + ": Open Response Question"
        o.description = ""
        o.prompt = question_prompt
      end
      page_embeddable.pages << page
    end

    def add_drawing_response_to_page(page, question_prompt)
      add_xhtml_to_page(page, question_prompt) if page.page_elements.empty?
      page_embeddable = Embeddable::DrawingTool.create do |dt|
        dt.name = page.name + ": Drawing Tool"
        dt.description = "Drawing tool."
      end
      page_embeddable.pages << page
    end

    def add_prediction_graph_response_to_page(page, question_prompt)
      add_xhtml_to_page(page, question_prompt) if page.page_elements.empty?
      page_embeddable = Embeddable::DataCollector.create do |d|
        d.name = page.name + ": Prediction graph for #{@@first_probe_type.name}."
        d.title = d.name
        d.graph_type_id = 2
        d.probe_type = @@first_probe_type
        d.description = "This a Prediction graph for #{@@first_probe_type.name} into which a student can draw graph data."
      end
      @@prediction_graph = page_embeddable
      page_embeddable.pages << page
    end

    def add_data_collector_to_page(page, probe_type, multiple_graphs)
      page_embeddable = Embeddable::DataCollector.create do |d|
        d.name = page.name + ": #{probe_type.name} Data Collector"
        d.title = d.name
        d.probe_type = probe_type
        d.multiple_graphable_enabled = multiple_graphs
        if @@prediction_graph
          d.prediction_graph_source = @@prediction_graph
          @@prediction_graph = nil
        end
        d.description = "This a Data Collector Graph that will collect data from a #{probe_type.name} sensor."
      end
      page_embeddable.pages << page
    end

    def add_xhtml_to_page(page, html_content)
      page_embeddable = Embeddable::Xhtml.create do |x|
        x.name = page.name + ": Body Content (html)"
        x.description = ""
        x.content = html_content
      end
      page_embeddable.pages << page
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


