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

    def materials_data(materials, assigned_to_class = nil)
      data = []

      if assigned_to_class
        portal_clazz = Portal::Clazz.find(assigned_to_class)
        active_assigned_materials = portal_clazz.active_offerings.map { |offering| "#{offering.runnable_type}::#{offering.runnable_id}" }
      else
        active_assigned_materials = []
      end

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

        #
        # Find favorite data
        #
        is_favorite = false
        favorite_id = nil

        if  current_user                        &&
            !current_user.anonymous?            &&
            material.respond_to?(:favorites)

          favorites = material.favorites.where(:user_id => current_user.id)
          if favorites.count > 0
            favorite_id = favorites[0].id
            is_favorite = true

          end
        end

        #
        # Add subject_areas and grade_levels
        # from the ActsAsTaggableOn associated properties lists.
        #
        tags = {}
        tags['subject_areas']   = []
        tags['grade_levels']    = []

        tags.each do |key, value|
            list = material.send(key)
            list.each do |o|
                tags[key].push o.name
            end
        end

        slug = material.name.respond_to?(:parameterize) ? material.name.parameterize : nil
        stem_resource_type = material.respond_to?(:lara_sequence?) ? (material.lara_sequence? ? 'sequence' : 'activity') : material.class.name.downcase

        projects = []
        if material.respond_to?(:projects)
          material.projects.select {|p| p.public}.each do |p|
            projects.push({
              name: p.name,
              url: p.landing_page_slug.nil? ? nil : view_context.project_page_url(p.landing_page_slug)
            })
          end
        end

        mat_data = {
          id: material.id,
          name: material.name,
          description: description,
          class_name: material.class.name,
          class_name_underscored: material.class.name.underscore,
          icon: {
            url: (material.respond_to?(:icon_image) ? material.icon_image : nil),
          },
          material_properties: material.material_property_list,
          is_official: material.is_official,
          is_archived: material.archived?,

          is_favorite: is_favorite,
          favorite_id: favorite_id,

          subject_areas:    tags['subject_areas'],
          grade_levels:     tags['grade_levels'],

          publication_status: material.publication_status,
          links: links_for_material(material),
          preview_url: view_context.run_url_for(material, (material.teacher_only? ? {:teacher_mode => true} : {})),
          edit_url: (material.is_a?(ExternalActivity) && policy(material).matedit?) ? view_context.matedit_external_activity_url(material, iFrame: true) : nil,
          unarchive_url: (material.is_a?(ExternalActivity) && policy(material).unarchive?) ? view_context.unarchive_external_activity_url(material) : nil,
          archive_url:   (material.is_a?(ExternalActivity) && policy(material).archive?) ? view_context.archive_external_activity_url(material) : nil,
          copy_url: external_copyable(material) ? view_context.copy_external_activity_url(material) : nil,
          assign_to_class_url: current_visitor.portal_teacher && material.respond_to?(:offerings) ? "javascript:get_Assign_To_Class_Popup(#{material.id},'#{material.class.to_s}','#{t('material').pluralize.capitalize}')" : nil,
          assign_to_collection_url: current_visitor.has_role?('admin') && material.respond_to?(:materials_collections) ? "javascript:get_Assign_To_Collection_Popup(#{material.id},'#{material.class.to_s}')" : nil,
          assigned_classes: assigned_clazz_names(material),
          class_count: material_count,
          sensors: view_context.probe_types(material).map { |p| p.name },
          has_activities: has_activities,
          has_pretest: has_pretest,
          activities: has_activities ? material.activities.map{ |a| {id: a.id, name: a.name} } : [],
          lara_activity_or_sequence: material.respond_to?(:lara_activity_or_sequence?) ? material.lara_activity_or_sequence? : false,
          parent: parent_data,
          user: user_data,
          assigned: active_assigned_materials.include?("#{material.class.name}::#{material.id}"),
          credits: material.respond_to?(:credits) ? material.credits : nil,
          slug: slug,
          stem_resource_url: view_context.stem_resources_url(stem_resource_type, material.id, slug),
          projects: projects
        }

        data.push mat_data
      end
      data
    end

    def external_copyable(material)
      if !(material.is_a? ExternalActivity)
        return false;
      end

      if material.launch_url.blank?
        return false;
      end

      return current_visitor.has_role?('admin','manager') ||
             (!material.is_locked && current_visitor.has_role?('author')) ||
             material.author_email == current_visitor.email
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
      if material.archived?
        if policy(material).unarchive?
          return  {
              unarchive: {
                url: unarchive_external_activity_url(material),
                text: t("matedit.unarchive"),
                ccConfirm: t("matedit.unarchive_confirm", {name: material.name})
              }
          }
        else
          return {}
        end
      end

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
        if policy(material).matedit?
          links[:external_edit] = {
            url: matedit_external_activity_url(material, iFrame: false),
            text: "Edit",
            target: '_blank'
          }
          links[:external_lara_edit] = {
            url: matedit_external_activity_url(material, iFrame: true),
            text: "Edit",
            target: '_blank'
          }
        end
        if external_copyable(material)
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

      if material.respond_to?(:print_url) && material.print_url.present?
        links[:print_url] = {
            text: "Print",
            target: "_blank",
            url: material.print_url
        }
      end

      if material.respond_to?(:teacher_guide_url) && !material.teacher_guide_url.blank?
        if current_visitor.portal_teacher || current_visitor.has_role?('admin','manager')
          links[:teacher_guide] = {
            text: "Teacher Guide",
            target: "_blank",
            url: material.teacher_guide_url
          }
        end
      end

      if policy(material).edit?
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
            onclick: "get_Assign_To_Class_Popup(#{material.id},'#{material.class.to_s}','#{t('material').pluralize.capitalize}')"
        }
      end

      if current_visitor.has_role?('admin') && material.respond_to?(:materials_collections)
        links[:assign_collection] = {
          text: "Add to Collection",
          url: "javascript:void(0)",
          onclick: "get_Assign_To_Collection_Popup(#{material.id},'#{material.class.to_s}','#{t('material').pluralize.capitalize}')"
        }
      end

      links
    end

    def assigned_clazz_names(material)
      return [] unless current_visitor.portal_teacher
      offerings = current_visitor.portal_teacher.offerings.includes(:runnable, :clazz).select { |o| o.runnable == material }
      offerings.map { |o| o.clazz.name }
    end
  end
end
