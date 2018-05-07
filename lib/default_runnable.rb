class DefaultRunnable

  class <<self

    def create_default_runnable_for_user(user, name="simple default #{TOP_LEVEL_CONTAINER_NAME}", logging=false)
      if APP_CONFIG[:use_jnlps] && TOP_LEVEL_CONTAINER_NAME == 'investigation'
        runnable = create_default_investigation_for_user(user, name, logging)
      else
        unless runnable = user.send(TOP_LEVEL_CONTAINER_NAME_PLURAL).find_by_name(name)
          runnable = TOP_LEVEL_CONTAINER_NAME.camelize.constantize.create do |i|
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
        investigation.deep_set_user(user)
      end
      investigation
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
      add_xhtml_to_page(page, "unsupported model type: #{model.model_type.name}")
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


