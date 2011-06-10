class DefaultRunnable

  class <<self

    def create_default_runnable_for_user(user, name="simple default #{TOP_LEVEL_CONTAINER_NAME}", logging=false)
      if USING_JNLPS && TOP_LEVEL_CONTAINER_NAME == 'investigation'
        runnable = create_default_investigation_for_user(user, name, logging)
      else
        unless runnable = user.send(TOP_LEVEL_CONTAINER_NAME_PLURAL).find_by_name(name)
          runnable = TOP_LEVEL_CONTAINER_CLASS.create do |i|
            i.name = name
            i.user = user
            i.description = "A simple default #{TOP_LEVEL_CONTAINER_NAME} automatically created for the user '#{user.login}'"
            case TOP_LEVEL_CONTAINER_NAME
              when 'external_activity'
                i.url = "http://redcloth.org/hobix.com/textile/quick.html"
              end
          end
        end
      end
      runnable.publish! unless runnable.publication_status == "published"
      runnable
    end
    
    def create_default_investigation_for_user(user, name, logging)
      puts
      @@prediction_graph = nil
      unless investigation = user.investigations.find_by_name(name)
        puts "creating '#{name}' Investigation for user '#{user.login}'"
        investigation = Investigation.create do |i|
          i.name = name
          i.user = user
          i.description = "A simple default Investigation"
        end
        activity = Activity.create do |i|
          i.name = 'Activity'
          i.description = "Learn About ..."
        end
        investigation.activities << activity
        section1 = DefaultRunnable.add_section_to_activity(activity, "Collect Data ...", "Collect Data using probes.")
        page1, xhtml = DefaultRunnable.add_page_to_section(section1, "Find the hottest",
          '<p>Find the hottest thing in the room with the temperature probe.</p>', 
          "Student's explore their environment with a tempemerature probe.")
        temperature_probe = Probe::ProbeType.find_by_name('temperature')
        DefaultRunnable.add_data_collector_to_page(page1, temperature_probe, false)
        investigation.deep_set_user(user)
      end
      investigation
    end

    def recreate_sensor_testing_investigation_for_user(user)
      name = "Sensor Testing"
      uuid = "576EE406-DCCF-4A5D-AE62-41DB3A098F4D"
      description = "An activity with one data collector for each type of sensor"
      @@prediction_graph = nil
      old = Investigation.find_by_uuid(uuid)
      if old
        old.offerings.each {|o| o.delete }
        old.destroy
      end
      puts "creating '#{name}' for user '#{user.login}'"
      investigation = Investigation.create( :name => name, :description => description, :uuid => uuid)
      counter = 1
      Probe::ProbeType.all.sort{ |a,b| a.name.downcase <=> b.name.downcase}.each do |type|
        description = "activity for testing #{type.name} data collection"
        activity = Activity.create( :name => type.name, :description => description )
        investigation.activities << activity
        type.calibrations.sort{ |a,b| a.name.downcase <=> b.name.downcase}.each do |calibration|
          section = DefaultRunnable.add_section_to_activity(activity, calibration.name, calibration.description)
          data_collector_for(section,type,calibration)
          counter = counter + 1
        end
        # and add one without a calibration
        section = DefaultRunnable.add_section_to_activity(activity, "(no calibration)", "probe #{type.name} with no calibration")
        data_collector_for(section,type,nil)
        counter = counter + 1
      end
      investigation.deep_set_user(user)
      investigation
    end

    def data_collector_for(section,type,calibration)
      if calibration
        calibration_name = calibration.name
        calibration_desc = calibration.description
        unit = calibration.physical_unit.unit_symbol
        y_axis_label = calibration.name
      else
        calibration_name = "no calibration"
        calibration_desc = "without any calibration"
        unit = type.unit
        y_axis_label = type.name
      end
      name = "#{type.name}- #{calibration_name}"
      description = "<h3>#{type.name} (id:#{type.id})"
      description << "- #{calibration_name} </h3>"
      description << "<p>probe #{type.name}<br/>#{calibration_desc}</p>"
      description << "<hr/>"
      page,xhtml = DefaultRunnable.add_page_to_section(section,name,description)
      data_collector = Embeddable::DataCollector.create(
        :name => name,
        :probe_type => type,
        :calibration => calibration,
        :y_axis_label => y_axis_label,
        :y_axis_units => unit,
        :y_axis_min => type.min,
        :y_axis_max => type.max
      )
      data_collector.pages << page
    end

    def add_page_to_section(section, name, html_content='', page_description='')
      if html_content.empty?
        page = Page.create do |p|
          p.name = "#{name}"
          p.description = page_description
        end
        page_embeddable = nil
      else
        page_embeddable = Embeddable::Xhtml.create do |x|
          x.name = name + ": Body Content (html)"
          x.description = ""
          x.content = html_content
        end
        page = Page.create do |p|
          p.name = "#{name}"
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


