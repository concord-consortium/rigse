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

  class MissingUuid < ImporterException
    def initialize(opts)
      super("Object did not have a UUID",opts)
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
    attr_accessor :exceptions
    STARTED = 0
    FAILED = -1
    SUCCESS = 1
    def initialize(_diy_id)
      self.diy_id = _diy_id
      self.start_time = Time.now
      self.status = ActivityImportRecord::STARTED
      self.exceptions = []
    end
    def fail(exception)
      self.end_time = Time.now
      self.status=ActivityImportRecord::FAILED
      self.exceptions << exception
    end
    def finish(activity)
      self.status=ActivityImportRecord::SUCCESS
      self.uuid = activity.uuid
      self.portal_id = activity.id
      self.name = activity.id
    end
    def errors
      self.exceptions.map { |e| e.message}
    end
    def report
      case self.status
      when SUCCESS
        return "#{self.diy_id}: sucess"
      when FAILED
        return "#{self.diy_id}: failed: " << self.errors.join("\n\t")
      when STARTED
        return "#{self.diy_id}: in-progress: " << self.errors.join("\n\t")
      end
    end

  end
  
  # When importing from the portal, skip units matching
  # the following regex:
  SKIP_UNIT_REGEX = /tests/i

  SUBSECTIONS=%w[
        text_response
        drawing_response
        model_active
        model_id
        probe_active
        probetype_id
        probe_multi
        calibration_active
        calibration_id].map { |e| e.to_sym }

  ACTIVITY_TEMPLATE_UUID = "7d7f511d-45c6-4002-a5d8-6d6d63a7f12d"
  SECTIONS_MAP = [
    { :key => :introduction,
      :enabled => true,
      :name => "Introduction",
      :page_desc => "ITSI Activities start with a Discovery Question.",
      :embeddable_elements => [
        {:key => :main_content,    :diy_attribute => true},
        {:key => :text_response,   :diy_attribute => true},
        {:key => :text_response,   :diy_attribute => false},
        {:key => :drawing_response,:diy_attribute => true}
      ]
    },
    { :key => :standards,
      :enabled => false,
      :name => "Standards",
      :page_desc => "What standards does this ITSI Activity cover?",
      :embeddable_elements => [
        {:key => :main_content, :diy_attribute => true},
      ]
    },
    { :key => :career_stem,
      :enabled => false,
      :name => "Career STEM Question",
      :page_desc => "Career STEM Question",
      :embeddable_elements => [
        {:key => :main_content, :diy_attribute => true},
        {:key => :text_response, :diy_attribute => true},
        {:key => :text_response, :diy_attribute => false},
      ]
    },
    { :key => :materials,
      :enabled => false,
      :name => "Materials",
      :page_desc => "What materials does this ITSI Activity require?",
      :embeddable_elements => [
        {:key => :main_content, :diy_attribute => true}
      ]
    },
    { :key => :safety,
      :enabled => false,
      :name => "Safety",
      :page_desc => "Are there any safety considerations to be aware of in this ITSI Activity?",
      :embeddable_elements => [
        {:key => :main_content, :diy_attribute => true}
      ]
    },
    { :key => :proced,
      :enabled => false,
      :name => "Procedure",
      :page_desc => "What procedures should be performed to get ready for this ITSI Activity?.",
      :embeddable_elements => [
        {:key => :main_content,     :diy_attribute => true  },
        {:key => :drawing_response, :diy_attribute => true  }
      ]
    },
    { :key => :predict,
      :enabled => false,
      :name => "Prediction I",
      :page_desc => "Have the learner think about and predict the outcome of an experiment.",
      :embeddable_elements => [
        {:key => :main_content,     :diy_attribute => true },
        {:key => :prediction_graph, :diy_attribute => true }, 
        {:key => :prediction_draw,  :diy_attribute => true }, 
        {:key => :prediction_text,  :diy_attribute => true }, 
      ]
    },
    { :key => :collectdata,
      :enabled => false,
      :name => "Collect Data I",
      :page_desc => "The learner conducts experiments using probes and models.",
      :embeddable_elements => [
        {:key => :main_content,     :diy_attribute => true  },
        {:key => :probetype_id,     :diy_attribute => true  },
        {:key => :model_id,         :diy_attribute => true  },
        {:key => :text_response,    :diy_attribute => true  },
        {:key => :text_response,    :diy_attribute => false },
        {:key => :drawing_response, :diy_attribute => true  }
      ]
    },
    { :key => :prediction2,
      :enabled => false,
      :name => "Prediction II",
      :page_desc => "Have the learner think about and predict the outcome of an experiment.",
      :embeddable_elements => [
        {:key => :main_content,     :diy_attribute => false }, # doesn't exist in DIY
        {:key => :prediction_graph, :diy_attribute => true  },
        {:key => :prediction_draw,  :diy_attribute => false }, # doesn't exist in DIY
        {:key => :prediction_text,  :diy_attribute => false }, # doesn't exist in DIY
      ]
    },
    { :key => :collectdata2,
      :enabled => false,
      :name => "Collect Data II",
      :page_desc => "The learner conducts experiments using probes and models.",
      :embeddable_elements => [
        {:key => :main_content,       :diy_attribute => true },
        {:key => :probetype_id,       :diy_attribute => true },
        {:key => :model_id,           :diy_attribute => true },
        {:key => :text_response,      :diy_attribute => true },
        {:key => :text_response,      :diy_attribute => false},
        {:key => :drawing_response,   :diy_attribute => true }
      ]
    },
    { :key => :prediction3,
      :enabled => false,
      :name => "Prediction III",
      :page_desc => "Have the learner think about and predict the outcome of an experiment.",
      :embeddable_elements => [
        {:key => :main_content,     :diy_attribute => false },
        {:key => :prediction_graph, :diy_attribute => false }, # doesn't exist in DIY
        {:key => :prediction_draw,  :diy_attribute => false }, # doesn't exist in DIY
        {:key => :prediction_text,  :diy_attribute => false }, # doesn't exist in DIY
      ]
    },

    { :key => :collectdata3,
      :enabled => false,
      :name => "Collect Data III",
      :page_desc => "The learner conducts experiments using probes and models.",
      :embeddable_elements => [
        {:key => :main_content,     :diy_attribute => true },
        {:key => :probetype_id,     :diy_attribute => true  },
        {:key => :model_id,         :diy_attribute => true  },
        {:key => :text_response,    :diy_attribute => true  },
        {:key => :text_response,    :diy_attribute => false  },
        {:key => :drawing_response, :diy_attribute => true  }
      ]
    },
    { :key => :analysis,
      :enabled => false,
      :name => "Analysis",
      :page_desc => "How can learners reflect and analyze the experiments they just completed?",
      :embeddable_elements => [
        {:key => :main_content,      :diy_attribute => true },
        {:key => :text_response,     :diy_attribute => true  },
        {:key => :drawing_response,  :diy_attribute => true  },
        {:key => :text_response,     :diy_attribute => false },
        {:key => :text_response,     :diy_attribute => false },
        {:key => :text_response,     :diy_attribute => false },
        {:key => :text_response,     :diy_attribute => false },
        {:key => :text_response,     :diy_attribute => false },
      ]
    },
    { :key => :conclusion,
      :enabled => false,
      :name => "Conclusion",
      :page_desc => "What are some reasonable conclusions a learner might come to after this ITSI Activity?",
      :embeddable_elements => [
        {:key => :main_content,     :diy_attribute => true },
        {:key => :text_response,    :diy_attribute => true  },
        {:key => :drawing_response, :diy_attribute => true  }
      ]
    },
    { :key => :career_stem2,
      :enabled => true,
      :name => "Second Career STEM Question",
      :page_desc => "Second Career STEM Question",
      :embeddable_elements => [
        {:key => :main_content,  :diy_attribute => true },
        {:key => :text_response, :diy_attribute => true  },
        {:key => :text_response, :diy_attribute => false  },
      ]
    },
    { :key => :prediction4,
      :enabled => false,
      :name => "Prediction IV",
      :page_desc => "Have the learner think about and predict the outcome of an experiment.",
      :embeddable_elements => [
        {:key => :main_content,     :diy_attribute => false },
        {:key => :prediction_graph, :diy_attribute => false }, # doesn't exist in DIY
        {:key => :prediction_draw,  :diy_attribute => false }, # doesn't exist in DIY
        {:key => :prediction_text,  :diy_attribute => false }, # doesn't exist in DIY
      ]
    },
    { :key => :further,
      :enabled => false,
      :name => "Further Investigation",
      :page_desc => "Think about any further activities a learner might want to try.",
      :embeddable_elements => [
        {:key => :main_content,     :diy_attribute => true  },
        {:key => :probetype_id,     :diy_attribute => true  },
        {:key => :model_id,         :diy_attribute => true  },
        {:key => :text_response,    :diy_attribute => true  },
        {:key => :text_response,    :diy_attribute => false  },
        {:key => :drawing_response, :diy_attribute => true  }
      ]
    }
  ]

  @errors = []

  class <<self
    def find_or_create_itsi_import_user
      unless user = User.find_by_login('itsi_import_user')
        user = User.create(:login => 'itsi_import_user', :first_name => 'ITSI', :last_name => 'Importer', :email => 'itsi_import_user@concord.org', :password => "it$iu$er", :password_confirmation => "it$iu$er")
        user.save
        user.register!
        user.activate!
        user.add_role('member')
        user.add_role('author')
      end
      user
    end


    def make_activity
      act = Activity.create do |t|
        t.name = Activity.gen_unique_name("Blank Activity")
        t.description = "Single-page Activity"
        t.user = ItsiImporter.find_or_create_itsi_import_user
      end
      the_prediction_graph = nil
      SECTIONS_MAP.each do |section_def|
        section = Section.create!(:name => section_def[:name], :description => section_def[:name], :activity => act, :user => act.user)
        page = Page.create!(:name => section_def[:name], :description => section_def[:page_desc], :section => section, :user => act.user)
        page.is_enabled = section_def[:enabled]
        section.is_enabled = section_def[:enabled]
        section.pages << page
        act.sections << section
        components = section_def[:embeddable_elements]
        components.each do |comp|
          elem = comp[:key]
          page_elem = nil
          case elem
            when :main_content
              #embeddable = Embeddable::Diy::Section.create!(:name => section_def[:name], :content => section_def[:page_desc], :has_question => false, :user => act.user)
              embeddable = Embeddable::Diy::Section.create!(:name => section_def[:name], :content => "", :has_question => false, :user => act.user)
            when :probetype_id
              probe_type = Probe::ProbeType.default
              prototype_data_collector = Embeddable::DataCollector.get_prototype({:probe_type => probe_type, :calibration => nil, :graph_type => 'Sensor'})
              embeddable = Embeddable::Diy::Sensor.create!(:prototype => prototype_data_collector, :user => act.user)
              # you must define prediction graph before the probe!
              unless the_prediction_graph.nil?
                embeddable.prediction_graph_source = the_prediction_graph
                embeddable.save
                the_prediction_graph = nil
              end
            when :model_id
              model = Diy::Model.first
              if (model.nil?)
                model_type = Diy::ModelType.create!(:name => "prototype", :diy_id => 99999, :otrunk_view_class => "OTBlah", :otrunk_object_class => "OTBlahView")
                model = Diy::Model.create!(:model_type => model_type, :diy_id => 99999, :name => "prototype" )
              end
              embeddable = Embeddable::Diy::EmbeddedModel.create!(:diy_model => model, :user => act.user)
            when :text_response
              embeddable = Embeddable::OpenResponse.create!(:name => "written response", :description => "written response")
            when :drawing_response
              embeddable = Embeddable::DrawingTool.create(:name => "drawing response", :description => "drawing response", :user => act.user)
            when :prediction_graph
              probe_type = Probe::ProbeType.default
              prototype_prediction = Embeddable::DataCollector.get_prototype({:probe_type => probe_type, :graph_type => 'Prediction'})
              embeddable = Embeddable::Diy::Sensor.create!(:prototype => prototype_prediction, :user => act.user)
              the_prediction_graph=embeddable
            when :prediction_text
              embeddable = Embeddable::OpenResponse.create(:name => "written prediction", :description => "written prediction")
            when :prediction_draw
              embeddable = Embeddable::DrawingTool.create(:name => "drawn prediction", :description => "drawn precition", :user => act.user)
          end
          if ! embeddable.nil?
            embeddable.pages << page
            # leave the main_content enabled since there is no UI to enable or disable it
            embeddable.disable unless elem == :main_content
            # store this for later use...
            comp[:embeddable] = embeddable
          end
        end
      end
      log "made #{act.name} (#{act.id})"
      return act
    end

    def find_or_create_itsi_activity_template
      act = Activity.find_by_uuid(ACTIVITY_TEMPLATE_UUID)
      # TODO: this is sort of ugly: We create a new one if one exists, because we need to map embeddables
      if act
        log "removing old ITSI Template - Activity #{act.id}"
        act.destroy
      end
      act = make_activity
      act.name = "Single-page Activity Template"
      act.description = "Single-page Activity Template"
      act.user = ItsiImporter.find_or_create_itsi_import_user
      act.is_template = true
      act.uuid = ACTIVITY_TEMPLATE_UUID
      act.save
    end

    def delete_itsi_activity_template
      act = Activity.find_by_uuid(ACTIVITY_TEMPLATE_UUID)
      log "No template could be found" unless act
      return unless act
      log "Deleting Activity #{act.id}"
      act.destroy
    end

    # NOTE: this doesn't correctly set the x and y axis ranges, units, title, and y axis label for the calibrations
    # however there are only a handful, so for now you need to manually tweak them
    def setup_prototype_data_collectors
      types = Probe::ProbeType.find :all
      types.each do |probe_type|
        prototype = Embeddable::DataCollector.get_prototype({:probe_type => probe_type, :graph_type => 'Sensor'})
        prototype.name = probe_type.name
        prototype.save
      end
      calibrations = Probe::Calibration.find :all
      calibrations.each do |calibration|
        prototype = Embeddable::DataCollector.get_prototype({:probe_type => calibration.probe_type, :calibration => calibration, :graph_type => 'Sensor'})
        prototype.name = calibration.name
        prototype.save
      end
      DIY_HACK_CALIBRATIONS.each do |id, options|
        prototype = Embeddable::DataCollector.get_prototype({:probe_type => Probe::ProbeType.find(7), :graph_type => 'Sensor', :extra_options => options.clone})
        prototype.name = options[:name]
        prototype.save
      end
    end

    def reject_cc_portal_unit?(unit)
      return unit.unit_name.match(/Test/)
    end

    def import_from_cc_portal
      raise "need an 'ccportal' specification in database.yml to run this task" unless ActiveRecord::Base.configurations['ccportal']
      ccp_itsi_project = Ccportal::Project.find_by_project_name('ITSISU')
      #units = ccp_itsi_project.units.reject { |u| u.name =~ SKIP_UNIT_REGEX }
      units = ccp_itsi_project.units.reject  { |u| reject_cc_portal_unit?(u) }
      puts "importing #{units.length} ITSISU Units ..."
      reset_errors
      units.each do |ccp_itsi_unit|
        create_activities_from_ccp_itsi_unit(ccp_itsi_unit, "")
      end
      puts import_report
    end

    def create_activities_from_ccp_itsi_unit(ccp_itsi_unit, prefix="")
      # Carolyn and Ed wanted this the prefix removed for the itsi-su importer
      name = "#{prefix} #{ccp_itsi_unit.unit_name}".strip
      log "creating: #{name}: "
      ccp_itsi_unit.activities.each do |ccp_itsi_activity|
        foreign_key = ccp_itsi_activity.diy_identifier
        activity = create_activity_from_itsi_activity(foreign_key, nil, prefix) # nil user will import the DIY user and associate the activity with that user
        if activity
          activity.unit_list = ccp_itsi_unit.unit_name
          activity.grade_level_list = ccp_itsi_activity.level.level_name
          activity.subject_area_list = ccp_itsi_activity.subject.subject_name
          activity.publish! unless activity.published?
          activity.is_exemplar = true
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

    def remove_existing_activity(activity)
      if activity.offerings.size > 0
        log("deactivating offerings for #{activity.name}")
        activity.offerings.each { |o| o.deactivate!}
        activity.is_template = false
        if activity.public?
          activity.un_publish!
        end
        activity.uuid = nil
        activity.generate_uuid
        activity.save
      else
        activity.destroy
      end
      activity = nil
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

          # TODO: How do we handle updating if the template has changed??
          # For now we just delete and re-import. Not very great.
          if activity
            remove_existing_activity(activity)
          end
          activity = make_activity
          activity.name = Activity.gen_unique_name name
          activity.user = user
          activity.description = itsi_activity.description
          activity.uuid = itsi_activity.uuid
          activity.publish if itsi_activity.public
          SECTIONS_MAP.each do |section|
            process_diy_activity_section(activity,itsi_activity,section)
          end
          log "  ITSI: #{itsi_activity.id} - #{itsi_activity.name}"
          activity.save
          finish(activity)
          return activity
        rescue ActiveRecord::RecordNotFound
          message = "  -- itsi activity id: #{foreign_key} not found --"
          self.fail(NotFoundInDiy.new({:diy_id => foreign_key}), message)
        end
      else
        message = "  -- foreign key empty for ITSI Activity --"
        self.fail(NotFoundInDiy.new({:diy_id => foreign_key}),message)
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


    def attribute_name_for(section_key, attribute_name)
      # see initializers/00_core_extensions.rb for the array modification to_hash_keys
      attribs = SUBSECTIONS.to_hash_keys { |k| "#{section_key}_#{k.to_s}".to_sym }
      # There are some exceptions for the subsection naming conventions in the diy models:
      case section_key
      when :predict
        attribs[:prediction_graph]     = :prediction_graph_response
        attribs[:prediction_text]      = :prediction_text_response
        attribs[:prediction_draw]      = :prediction_drawing_response
      when :collectdata
        attribs[:probetype_id]         = :probe_type_id
        attribs[:model_id]             = :model_id
        attribs[:calibration_active]   = :collectdata1_calibration_active
        attribs[:calibration_id]       = :collectdata1_calibration_id
      when :prediction2
        attribs[:prediction_graph]     = :collectdata_graph_response
      when :further
        attribs[:calibration_active]   = :furtherprobe_calibration_active
        attribs[:calibration_id]       = :furtherprobe_calibration_id
      end
      return attribs[attribute_name]
    end

    def attribute_for(activty,section_key,attribute)
      begin
        method_name = attribute_name_for(section_key, attribute)
        return nil unless method_name
        return activty.send method_name
      rescue NoMethodError
        error("No Method #{method_name} for #{section_key} in #{activty.name}")
        return nil
      rescue TypeError
      end
      return nil
    end

    def model_id(activity,section_key)
      if attribute_for(activity,section_key, :model_active)
        return attribute_for(activity,section_key,:model_id)
      end
    end

    def probetype_id(activity,section_key)
      if attribute_for(activity,section_key, :probe_active)
        return attribute_for(activity,section_key,:probetype_id)
      end
    end

    def prediction_graph(activity,section_key)
      attribute_for(activity,section_key,:prediction_graph)
    end

    def calibration_id(activity,section_key)
      if attribute_for(activity,section_key, :calibration_active)
        return attribute_for(activity,section_key,:calibration_id)
      end
    end

    def enable_section_for(emb)
      emb.pages.each do |p| 
        p.is_enabled = true 
        p.save
        if p.section
          p.section.is_enabled = true
          p.section.save
        end
      end
      emb.enable
      emb.save
    end

    def set_embeddable(embeddable,symbol,value)
      begin
        embeddable.send(symbol, value)
        enable_section_for(embeddable)
      rescue NoMethodError => e
        @errors << e
        errror("No method #{symbol} in #{embeddable.class.name}")
      end
    end

    ##
    def process_diy_activity_section(activity,diy_act,section_def)
      section_key = section_def[:key]
      section_def[:embeddable_elements].each do |element|
        diy_attribute = element[:diy_attribute]
        embeddable = element[:embeddable]
        type_key = element[:key]
        working_chunk = "#{section_key} #{type_key}"
        #log "processing #{working_chunk}"
        if diy_attribute
          if embeddable
            type_key_string = type_key.to_s
            method_symbol = "process_#{type_key_string}".to_sym
            begin
              self.send(method_symbol,embeddable,diy_act,section_def)
            rescue NoMethodError => e
              error "Importer: no such method #{method_symbol} for #{embeddable.class} in #{section_key}"
              puts e.inspect
              puts e.backtrace
            rescue ItsiImporter::ImporterException => e
              @errors << e
            end
          else
            error "skipping #{working_chunk} -- no embeddable"
          end
        else
          log "skipping #{working_chunk} -- diy_attribute is false"
        end
      end # embeddable_elements itt
    end

    def process_main_content(embeddable,diy_act,section_def)
        if diy_act.textile
          orig_content = diy_act.send(section_def[:key].to_sym)
          content,prompt = process_textile_content(orig_content,false)
        else
          # if we don't use textile, just use text directly.
          content = diy_act.send(section_def[:key].to_sym)
        end
        embeddable.content = content
        if content && (!content.empty?)
          enable_section_for(embeddable)
        end
    end


    # there are some calibrations in the DIY that aren't really calibrations, they were just
    # used to set the x and y axis range.
    DIY_HACK_CALIBRATIONS = {
      8 => {
        :name => "Motion Sensor: track and ramp",
        :y_axis_min => 0,
        :y_axis_max => 5,
        :x_axis_min => 0,
        :x_axis_max => 60,
      },
      9 => {
        :name => "Motion Sensor: dropping objects",
        :y_axis_min => 0,
        :y_axis_max => 3,
        :x_axis_min => 0,
        :x_axis_max => 10,
      },
      10 => {
        :name => "Motion Sensor: up and down",
        :y_axis_min => -1,
        :y_axis_max => 1,
        :x_axis_min => 0,
        :x_axis_max => 60,
      },
    }
    
    def process_probetype_id(embeddable,diy_act,section_def)
      section_key = section_def[:key]
      probe_type_id=probetype_id(diy_act,section_key)
      if probe_type_id
        begin
          probe_type = Probe::ProbeType.find(probe_type_id)
          # this might not find the probe type, some probes are in the DIY but haven't been added 
          # to the rails-portal, this can be fixed by updating the rails-portal list
          calibration_id = calibration_id(diy_act,section_key)
          calibration = nil
          extra_options = nil
          if calibration_id
            extra_options = DIY_HACK_CALIBRATIONS[calibration_id]
            calibration = Probe::Calibration.find(calibration_id) unless extra_options
          end
          prototype_data_collector = Embeddable::DataCollector.get_prototype({:probe_type => probe_type, :calibration => calibration, :graph_type => 'Sensor'})
          set_embeddable(embeddable, :prototype=, prototype_data_collector)
        rescue ActiveRecord::RecordNotFound => e
          message = "#{e}. activity => #{diy_act.name} (#{diy_act.id}) probe_type.id => #{probe_type_id}"
          @errors << ItsiImporter::ImporterException.new(message,{:diy_act => diy_act, :root_cause => e})
        end
      end
    end

    def process_model_id(embeddable,diy_act,section_def)
      section_key = section_def[:key]
      model_id = model_id(diy_act,section_key)
      if model_id
        begin
          diy_model = Itsi::Model.find(model_id)
          if diy_model
            model = Diy::Model.from_external_portal(diy_model)
            set_embeddable(embeddable,:diy_model=,model)
          end
        rescue => e
          log "#{e}. activity => #{diy_act.name} #{diy_act.id}"
          @errors << BadModel.new({:diy_activity => diy_act, :model_id => model_id })
        end
      end
    end

    def process_prediction_graph(embeddable,diy_act,section_def)
      section_key = section_def[:key]
      graph_response = prediction_graph(diy_act,section_key)
      if graph_response
        probe_type_id = probetype_id(diy_act,section_key)
        set_embeddable(embeddable,:graph_type=, 'Prediction')
      end
    end

    def process_text_response(embeddable,diy_act,section_def)
      value = attribute_for(diy_act,section_def[:key], :text_response)
      if value
        embeddable.enable
        embeddable.prompt = ""
        enable_section_for(embeddable)
      end
    end

    def process_drawing_response(embeddable,diy_act,section_def)
      value = attribute_for(diy_act,section_def[:key], :drawing_response)
      enable_section_for(embeddable) if value
    end

    def process_prediction_text(embeddable,diy_act,section_def)
      value = attribute_for(diy_act,section_def[:key],:prediction_text)
      if value
        embeddable.enable
        embeddable.prompt = ""
        enable_section_for(embeddable) if value
      end
    end

    def process_prediction_draw(embeddable,diy_act,section_def)
      value = attribute_for(diy_act,section_def[:key], :prediction_draw)
      enable_section_for(embeddable) if value
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

    def error(message)
      log message
      @errors << ImporterException.new(message)
    end

    def start(diy_id)
      @records ||= []
      if @records.last && @records.last.status == ActivityImportRecord::STARTED
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
        log("Finish called before start for #{activity.name}") unless record
        log("Import failed already for #{activity.name}") if record && record.status == ActivityImportRecord::FAILED
      end
    end

    def fail(exception, message)
      log exception.message
      log message
      @records.last.fail(exception)
      @errors ||= []
      @errors << exception
    end

    def reset_errors
      @records = []
      @errors  = []
    end

    def import_report
      total_activity_attempts = @records.size
      failures = @records.select  { |r| r.status == ActivityImportRecord::FAILED }
      completed = @records.select { |r| r.status == ActivityImportRecord::SUCCESS}
      aborted = @records.select   { |r| r.status == ActivityImportRecord::STARTED}
      summary = "#{completed.size}/#{total_activity_attempts} completed (#{failures.size} failed, #{aborted.size} aborted)"
      details = failures.map { |f| f.report }.join("\n")
      summary << "\n" << details
    end

    def error_report
      @errors.map { |e| e.message}.join("\n")
    end

  end # end of class methods
end
