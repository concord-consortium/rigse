class ItsiImporter

  class ImporterException < Exception
    attr_accessor :activity
    attr_accessor :time
    attr_accessor :fatal
    def initialize(msg,opts={:fatal=>true})
      super(msg)
      self.time = Time.now
      self.options=opts
    end
    def options=(opts)
      @options=opts
      process_options
    end
    def process_options
      self.activity = @options[:activity]
      self.fatal = @options[:fatal]
    end
    def options
      @options
    end
  end

  class NotFoundInDiy < ImporterException
    def initialize(opts)
      super("Could not find object in the DIY",opts)
    end
  end

  class NotFoundInPhpPortal < ImporterException
    def initialize(opts)
      super("Could not find object in the php portal",opts)
    end
  end

  class DuplicateUuid < ImporterException
    def initialize(opts)
      super("Object had a duplicate UUID",opts)
    end
  end

  class MissingUuid < ImporterException
    def initialize(opts)
      super("Object did not have a UUID",opts)
    end
  end

  class BadModelType < ImporterException
    def initialize(opts)
      super("Bad Model Type",opts)
    end
  end

  class BadModel < ImporterException
    def initialize(opts)
      super("Bad Model",opts)
    end
  end

  class BadActivity < ImporterException
    def initialize(opts)
      super("Bad Activity",opts)
    end
  end

  class ValidationError < ImporterException
    def initialize(opts)
      super("Validation Error",opts)
    end
  end

  class BadUser < ImporterException
    def initialize(opts)
      super("Bad User",opts)
    end
  end


  class ActivityImportRecord
    attr_accessor :name
    attr_accessor :diy_id
    attr_accessor :uuid
    attr_accessor :portal_id
    attr_accessor :status
    attr_accessor :start_time
    attr_accessor :end_time
    STARTED = 0
    FAILED = -1
    SUCCESS = 1
    def initialize(_diy_id)
      self.diy_id = _diy_id
      self.start_time = Time.now
      self.status = ActivityImportRecord::STARTED
    end
    def fail(exception)
      self.end_time = Time.now
      self.status=ActivityImportRecord::FAILED
    end
    def finish(activity)
      self.status=ActivityImportRecord::SUCCESS
      self.uuid = activity.uuid
      self.portal_id = activity.id
      self.name = activity.id
    end
  end

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
      :name => "Collect Data I",
      :page_desc => "The learner conducts experiments using probes and models.",
      :extra_elements => [:probe, :model, :text_response, :draw_response, :prediction_response]
    },
    { :key => :collectdata2,
      :name => "Collect Data II",
      :page_desc => "The learner conducts experiments using probes and models.",
      :extra_elements => [:probe, :model, :text_response, :draw_response]
    },
    { :key => :collectdata3,
      :name => "Collect Data III",
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

  @errors = []

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
      log "ITSI Template - Activity #{act.id}" if act
      return act if act

      act = Activity.create!(:name => "Single-page Activity Template", :description => "Single-page Activity Template", :user => ItsiImporter.find_or_create_itsi_import_user, :is_template => true ) {|a| a.uuid = ACTIVITY_TEMPLATE_UUID}
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
              model = Diy::Model.first
              if (model.nil?)
                model_type = Diy::ModelType.create!(:name => "prototype", :diy_id => 99999, :otrunk_view_class => "OTBlah", :otrunk_object_class => "OTBlahView")
                model = Diy::Model.create!(:model_type => model_type, :diy_id => 99999, :name => "prototype" )
              end
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
      log "ITSI Template - Activity #{act.id}"
      return act
    end

    def delete_itsi_activity_template
      act = Activity.find_by_uuid(ACTIVITY_TEMPLATE_UUID)

      log "No template could be found" unless act
      return unless act

      log "Deleting Activity #{act.id}"
      act.destroy
    end

    def create_activities_from_ccp_itsi_unit(ccp_itsi_unit, prefix="")
      # Carolyn and Ed wanted this the prefix removed for the itsi-su importer
      name = "#{prefix} #{ccp_itsi_unit.unit_name}".strip
      log "creating: #{name}: "
      ccp_itsi_unit.activities.each do |ccp_itsi_activity|
        foreign_key = ccp_itsi_activity.diy_identifier
        activity = create_activity_from_itsi_activity(foreign_key, nil, prefix) # nil user will import the DIY user and associate the activity with that user
        if actvity
          activity.unit_list = ccp_itsi_unit.unit_name
          activity.grade_level_list = ccp_itsi_activity.level.level_name
          activity.subject_area_list = ccp_itsi_activity.subject.subject_name
          activity.publish! unless activity.published?
          activity.save
        end
      end
      puts
    end

    def create_investigation_from_ccp_itsi_unit(ccp_itsi_unit, user, prefix="")
      # Carolyn and Ed wanted this the prefix removed for the itsi-su importer
      name = "#{prefix} #{ccp_itsi_unit.unit_name}".strip
      log "creating: #{name}: "
      investigation = Investigation.create do |i|
        i.name = name
        i.user = user
        i.description = "An ITSI unit is a collection of ITSI Activities"
      end
      ccp_itsi_unit.activities.each do |ccp_itsi_activity|
        foreign_key = ccp_itsi_activity.diy_identifier
        activity = create_activity_from_itsi_activity(itsi_activity, user, prefix="")
        investigation.activities << activity
        ItsiImporter.add_itsi_activity_to_investigation(investigation, itsi_activity, user,prefix)
        puts
      end
    end


    def create_activity_from_itsi_activity(foreign_key, user=nil, prefix="", use_number=false)
      unless foreign_key.empty?
        self.start(foreign_key)
        begin
          itsi_activity = Itsi::Activity.find(foreign_key)
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
          log "  ITSI: #{itsi_activity.id} - #{itsi_activity.name}"
          finish(activity)
          return activity
        rescue ActiveRecord::RecordNotFound
          message = "  -- itsi activity id: #{itsi_activity.id} not found --"
          self.fail(NotFoundInDiy.new({:diy_id => foreign_key, :unit_name => ccp_itsi_unit.unit_name}), message)
        end
      else
        message = "  -- foreign key empty for ITSI Activity --"
        self.fail(NotFoundInDiy.new({:diy_id => foreign_key, :unit_name => ccp_itsi_unit.unit_name}),message)
      end
      return false
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
          if c > 2
            @errors << BadUser(:user_id => diy_user.id, :user_uuid => diy_user.uuid, :activity => activity)
          else
            retry
          end
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
            @errors << BadModel.new({:activity => activity, :diy_activity => diy_act, :model_id => model_id })
          rescue => e
            log "#{e}. activity => #{diy_act.name} #{diy_act.id}"
            @errors << BadModel.new({:activity => activity, :diy_activity => diy_act})
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
            message = "#{e}. activity => #{diy_act.name} (#{diy_act.id}) probe_type.id => #{probe_type_id}"
            log message
            @errors << ItsiImporter::ImporterException(message,{:activity => activity, :diy_act => diy_act, :root_cause => e})
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
              log "#{e}. activity => #{diy_act.name} (#{diy_act.id})"
              @errors << ItsiImporter::ImporterException(message,{:activity => activity, :diy_act => diy_act, :root_cause => e})
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
          # we are also seeing things like this: &#8217;  =- &amp;#821We've had instances where the code would work when firebug is turned OFF and not work when it is turned on.  7; -- double encoded?
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

    def log(message,level=1)
      puts message
    end
  
    def start(diy_id)
      @records ||= []
      if @records.last && records.last.status == ActivityImportRecord::STARTED
        fail(ImporterException.new("Invalid importer state! Started record without fail or finish"))
      end
      @records.push ActivityImportRecord.new(diy_id)
    end

    def finish(activity)
      @records ||= [] # this is actually an error condition
      record = @records.last
      if record && record.status != ActivityImportRecord::FAILED
        if activity.valid?
          record.finish(activity)
        else
          self.fail(ValidationError.new(:activity => activity),"Activity fails validation #{activity.id} #{activity.name}")
        end
      else
        log ("Finish called before start for #{activity.name}") unless record
        log ("Import failed already for #{activity.name}") if record && record.status == ActivityImportRecord::FAILED
      end
    end

    def fail(exception, message)
      log exception.message
      log message
      @records.last.fail(exception)
      @errors ||= []
      @errors << exception
    end

  end # end of class methods
end

