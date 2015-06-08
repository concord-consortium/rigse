module Materials
  module DataHelpers
    # This module expects to be included into a controller, so that view_context resolves
    # to something that provides all the various view helpers.

    private

    # The main difference between this sanitization method and one provided by Rails natively is
    # is that Sanitize module *always* returns valid HTML input.
    def safe_sanitize(html_fragment)
      Sanitize.fragment(html_fragment, Sanitize::Config::BASIC)
    end

    def materials_data(materials)
      data = []

      materials.each do |material|
        parent_data = nil
        material_count = nil

        if material.respond_to?(:offerings_count)
          material_count = material.offerings_count
        end

        if material.respond_to?(:parent) && material.parent
          material_count = material_count + material.parent.offerings_count

          parent_data = {
            id: material.parent.id,
            type: view_context.t(:investigation),
            name: material.parent.name
          }
        end

        has_activities = material.respond_to?(:activities) && !material.activities.nil?
        has_pretest = material.respond_to?(:has_pretest) && material.has_pretest

        user_data = nil
        if material.user && (!material.user.name.nil?)
          user_data = {
            id: material.user.id,
            name: material.user.name
          }
        end

        # abstract_text is provided by SearchModelInterface and it fallbacks to normal description
        # if there is no abstract defined. It also truncates description in case of need.
        # Note that we can't use native #sanitize method provided by Rails, as it doesn't guarantee that
        # output is a valid HTML. Invalid HTML can totally break React view components.
        description = material.respond_to?(:description_for_teacher) && current_visitor.portal_teacher && material.description_for_teacher.present? ?
            safe_sanitize(material.description_for_teacher) : safe_sanitize(material.abstract_text)

        mat_data = {
          id: material.id,
          name: material.name,
          description: description,
          class_name: material.class.name,
          class_name_underscored: material.class.name.underscore,
          icon: {
            url: (material.respond_to?(:icon_image) ? material.icon_image : nil),
          },
          requires_java: material.java_requirements == SearchModelInterface::JNLPJavaRequirement,
          is_official: material.is_official,
          publication_status: material.publication_status,
          links: links_for_material(material),
          preview_url: view_context.run_url_for(material, (material.teacher_only? ? {:teacher_mode => true} : {})),
          assigned_classes: assigned_clazz_names(material),
          class_count: material_count,
          sensors: view_context.probe_types(material).map { |p| p.name },
          has_activities: has_activities,
          has_pretest: has_pretest,
          activities: has_activities ? material.activities.map{ |a| {id: a.id, name: a.name} } : [],
          parent: parent_data,
          user: user_data
        }

        data.push mat_data
      end
      data
    end

    def links_for_material(material)
      external = false
      if material.is_a? Investigation
        browse_url = browse_investigation_url(material)
      elsif material.is_a? Activity
        browse_url = browse_activity_url(material)
      elsif material.is_a? ExternalActivity
        browse_url = browse_external_activity_url(material)
        external = true
      elsif material.is_a? Interactive
        browse_url = interactive_url(material)
      end

      links = {
        browse: {
          url: browse_url
        }
      }

      if current_visitor.anonymous? or external
        links[:preview] = {
          url: view_context.run_url_for(material, {}),
          text: 'Preview',
          target: '_blank'
        }
      else
        if material.teacher_only?
          links[:preview] = {
            url: view_context.run_url_for(material, {:teacher_mode => true}),
            text: 'Preview',
            target: '_blank'
          }
        else
          links[:preview] = {
            type: 'dropdown',
            text: 'Preview &#9660;',
            expandedText: 'Preview &#9650;',
            url: 'javascript:void(0)',
            className: 'button preview_Button Expand_Collapse_Link',
            options: [
              {
                text: 'As Teacher',
                url: view_context.run_url_for(material, {:teacher_mode => true}),
                target: '_blank',
                className: ''
              },
              {
                text: 'As Student',
                url: view_context.run_url_for(material, {}),
                target: '_blank',
                className: ''
              }
            ]

          }
        end
      end

      if external && material.launch_url
        if current_visitor.has_role?('admin','manager') || (material.author_email == current_visitor.email)
          links[:external_edit] = {
            url: matedit_external_activity_url(material, iFrame: false),
            text: "Edit",
            target: '_blank'
          }
        end
        if current_visitor.has_role?('admin','manager') || (!material.is_locked && current_visitor.has_role?('author')) || material.author_email == current_visitor.email
          links[:external_copy] = {
            url: copy_external_activity_url(material),
            text: "Copy",
            target: '_blank'
          }
        end
        if current_visitor.has_role?('admin')
          links[:external_edit_iframe] = {
            url: matedit_external_activity_url(material, iFrame: true),
            text: "(edit in iframe)",
            target: '_blank',
            className: ''
          }
        end
      end

      if material.respond_to?(:teacher_guide_url) && !material.teacher_guide_url.blank?
        if current_visitor.portal_teacher || current_visitor.has_role?('admin','manager')
          links[:teacher_guide] = {
            text: "Teacher Guide",
            url: material.teacher_guide_url
          }
        end
      end

      if current_visitor.has_role?('admin','manager')
        links[:edit] = {
          text: "(portal settings)",
          url: edit_polymorphic_url(material),
          className: ''
        }
      end

      if current_visitor.portal_teacher && material.respond_to?(:offerings)
        links[:assign_material] = {
            text: "Assign to a Class",
            url: "javascript:void(0)",
            onclick: "get_Assign_To_Class_Popup(#{material.id},'#{material.class.to_s}')"
        }
      end

      if current_visitor.has_role?('admin') && material.respond_to?(:materials_collections)
        links[:assign_collection] = {
          text: "Add to Collection",
          url: "javascript:void(0)",
          onclick: "get_Assign_To_Collection_Popup(#{material.id},'#{material.class.to_s}')"
        }
      end

      links
    end

    def assigned_clazz_names(material)
      return [] unless current_visitor.portal_teacher
      offerings = current_visitor.portal_teacher.offerings.select { |o| o.runnable == material }
      offerings.map { |o| o.clazz.name }
    end
  end
end
