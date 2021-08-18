module Materials
  module DataHelpers
    # This module expects to be included into a controller, so that view_context resolves
    # to something that provides all the various view helpers.
    # Note that this module will be dealing only with ExternalActivity instances. In the past, it used to handle
    # Activity, Sequence and Interactive types too, but it's not a case anymore.
    private

    # The main difference between this sanitization method and one provided by Rails natively is
    # is that Sanitize module *always* returns valid HTML input.
    def safe_sanitize(html_fragment)
      html_fragment = "" if (html_fragment.nil?)
      Sanitize.fragment(html_fragment, Sanitize::Config::BASIC)
    end

    def materials_data( materials,
                        assigned_to_class       = nil,
                        include_related         = 0,
                        skip_lightbox_reloads   = false )
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

        if material.respond_to?(:has_teacher_edition)
          has_teacher_edition = material.has_teacher_edition
        else
          has_teacher_edition = false
        end

        if material.respond_to?(:saves_student_data)
          saves_student_data = material.saves_student_data
        else
          saves_student_data = true
        end

        user_data = nil
        if material.user && (!material.user.name.nil?)
          user_data = {
            id: material.user.id,
            name: material.user.name
          }
        end

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
        tags['sensors']    = []

        tags.each do |key, value|
            list = material.send(key)
            list.each do |o|
                tags[key].push o.name
            end
        end

        project_ids = material.projects.map { |p| p.id }

        projects = material.projects.map { |p|
            url = nil
            if p.landing_page_slug
                url = project_page_url(p.landing_page_slug)
            end

            {
                id:                 p.id,
                name:               p.name,
                landing_page_url:   url,
                public:             p.public
            }
        }

        #
        # Check if we should search for related material
        #
        related_materials = []
        if include_related > 0

            cohort_ids  = []
            user_id     = nil

            if ! current_user.nil?
                user_id = current_user.id
                if  current_user.portal_teacher &&
                    current_user.portal_teacher.cohorts

                    cohort_ids = current_user.portal_teacher.cohorts.map {|c| c.id}
                end
            end

            search = Sunspot.search(Search::DefaultSearchableModels) do

                fulltext "*" do
                    boost(5.0) { with(:project_ids, project_ids) }
                    boost(4.0) { with(:subject_areas, tags['subject_areas']) }
                    boost(2.0) { with(:grade_levels, tags['grade_levels']) }
                end

                any_of do
                    with    :published,     true
                    with    :user_id,       user_id
                end

                if current_user
                    if ! current_user.has_role? ['admin']
                        any_of do
                            with    :cohort_ids,    nil
                            with    :cohort_ids,    cohort_ids
                        end
                    end
                else
                    with :cohort_ids, nil
                end

                if current_user.nil? || current_user.only_a_student?
                    with(:is_assessment_item, false)
                end

                with        :is_archived,   false
                with        :is_official,   true
                without     material
                order_by    :score, :desc
                paginate    page: 1, per_page: include_related
            end

            related = search.results
            related_materials = materials_data(related)
        end

        slug = material.name.respond_to?(:parameterize) ? material.name.parameterize : nil
        stem_resource_type = material.respond_to?(:lara_sequence?) ? (material.lara_sequence? ? 'sequence' : 'activity') : material.class.name.downcase


        #
        # Include associated standards
        #
        standard_statements =
            StandardStatement.where(
                material_type: material.class.name.underscore,
                material_id: material.id).order("uri ASC")

        standard_statements_json = []

        standard_statements.each do |statement|
            standard_statements_json.push( {
                type:               statement.doc,
                uri:                statement.uri,
                parents:            statement.parents,
                notation:           statement.statement_notation,
                education_level:    statement.education_level,
                description:        statement.description
            });
        end

        #
        # Add license info
        #
        license_info_json = nil
        if material.respond_to?(:license) && material.license
            license = material.license
            license_info_json = {
                name:           license.name,
                code:           license.code,
                deed:           license.deed,
                legal:          license.legal,
                image:          license.image,
                description:    license.description,
                number:         license.number
            }
        end

        #
        # Determine if we should enable social media sharing
        #
        enable_sharing = true
        if material.is_a?(ExternalActivity) && material.respond_to?(:enable_sharing)
            enable_sharing = material.enable_sharing
        end

        #
        # Create stem_resource_url
        #
        stem_resource_url = nil
        if material.is_a?(ExternalActivity)
            stem_resource_url = view_context.stem_resources_url(material.id.to_i, slug)
        elsif material.is_a?(Interactive) && material.respond_to?(:external_activity_id)
            stem_resource_url = view_context.stem_resources_url(material.external_activity_id.to_i, slug)
        end

        mat_data = {
          id: material.id,
          name: material.name,
          # long_description_for_current_user returns long_description_for_teacher, long_description, or short_description.
          long_description_for_current_user: safe_sanitize(material.long_description_for_user(current_visitor)),
          # Raw db attribute, no fallback behavior.
          long_description: safe_sanitize(material.long_description),
          # Raw db attribute, no fallback behavior.
          long_description_for_teacher: safe_sanitize(material.long_description_for_teacher),
          # Raw db attribute, no fallback behavior.
          short_description: safe_sanitize(material.short_description),
          keywords: material.keywords,
          material_type: material.material_type,
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
          projects:         projects,

          publication_status: material.publication_status,

          #
          # Links for assigning materials to classes and collections
          #
          links: links_for_material(material, skip_lightbox_reloads),

          external_url: material.is_a?(ExternalActivity) ? material.url : nil,
          preview_url: view_context.run_url_for(material, view_context.preview_params(current_user, material.teacher_only? ? {:teacher_mode => true} : {})),
          edit_url: (material.is_a?(ExternalActivity) && policy(material).matedit?) ? view_context.matedit_external_activity_url(material, iFrame: true) : nil,
          unarchive_url: (material.is_a?(ExternalActivity) && policy(material).unarchive?) ? view_context.unarchive_external_activity_url(material) : nil,
          archive_url:   (material.is_a?(ExternalActivity) && policy(material).archive?) ? view_context.archive_external_activity_url(material) : nil,
          copy_url: external_copyable(material) ? view_context.copy_external_activity_url(material) : nil,
          assign_to_class_url: current_visitor.portal_teacher && material.respond_to?(:offerings) ? "javascript:PortalComponents.renderAssignToClassModal({material_id: #{material.id}, material_type: '#{material.class.to_s}', lightbox_material_text: '#{t('material').pluralize.capitalize}', skip_reload: true})" : nil,
          assign_to_collection_url: current_visitor.has_role?('admin') && material.respond_to?(:materials_collections) ? collections_external_activity_path(material) : nil,
          assigned_classes: assigned_clazz_names(material),
          class_count: material_count,
          sensors: tags['sensors'],
          has_teacher_edition: has_teacher_edition,
          has_activities: has_activities,
          has_pretest: has_pretest,
          saves_student_data: saves_student_data,
          activities: has_activities ? material.activities.map{ |a| {id: a.id, name: a.name} } : [],
          lara_activity_or_sequence: material.respond_to?(:lara_activity_or_sequence?) ? material.lara_activity_or_sequence? : false,
          parent: parent_data,
          user: user_data,
          assigned: active_assigned_materials.include?("#{material.class.name}::#{material.id}"),
          credits: material.respond_to?(:credits) ? material.credits : nil,
          created_at: material.created_at,

          license_info: license_info_json,

          related_materials: related_materials,

          standard_statements: standard_statements_json,

          enable_sharing: enable_sharing,

          slug: slug,

          stem_resource_url: stem_resource_url
        }

        data.push mat_data
      end
      data
    end

    def external_copyable(material)
      if !(material.is_a? ExternalActivity) || material.author_url.blank?
        return false
      end

      client = Client.where("site_url LIKE :ext_act_host", ext_act_host: "%#{URI.parse(material.author_url).host}%").first
      if client.nil?
        return false;
      end

      tool = Tool.where("tool_id LIKE :client_site_url", client_site_url: "%#{URI.parse(client.site_url).host}").first
      if tool.nil? || tool.remote_duplicate_url.blank?
        return false;
      end

      return current_visitor.has_role?('admin','manager') ||
             (!material.is_locked && current_visitor.has_role?('author')) ||
             material.author_email == current_visitor.email ||
             (!material.is_locked && material.teacher_copyable && current_visitor.portal_teacher.present?)
    end

    def links_for_material( material,
                            skip_lightbox_reloads = false )
      external = false
      if material.is_a? ExternalActivity
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

      preview_params = !current_user.nil? && current_user.portal_teacher ? {logging: true} : {}
      links[:preview] = {
        url: view_context.run_url_for(material, preview_params),
        text: 'Preview',
        target: '_blank'
      }

      if external && material.author_url.present?
        edit_in_iframe = !current_visitor.has_role?('author') && !current_visitor.has_role?('admin')
        if policy(material).matedit?
          links[:external_edit] = {
            url: matedit_external_activity_url(material, iFrame: edit_in_iframe),
            text: "Edit",
            target: '_blank'
          }
          links[:external_lara_edit] = {
            url: matedit_external_activity_url(material, iFrame: edit_in_iframe),
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

      if material.respond_to?(:teacher_resources_url) && !material.teacher_resources_url.blank?
        if current_visitor.portal_teacher || current_visitor.has_role?('admin','manager')
          links[:teacher_resources] = {
            text: "Teacher Resources",
            target: "_blank",
            url: material.teacher_resources_url
          }
        end
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

      assignPopupConfig = { :material_id => material.id, :material_type => material.class.to_s, :lightbox_material_text => t('material').pluralize.capitalize, :skip_reload => true }
      if !current_visitor.portal_student
        if current_visitor.portal_teacher && material.respond_to?(:offerings)
          assignPopupConfig[:anonymous] = false
        else
          assignPopupConfig[:anonymous] = true
        end

        links[:assign_material] = {
            text: "Assign or Share",
            url: "javascript:void(0)",
            onclick: "PortalComponents.renderAssignToClassModal(" + assignPopupConfig.to_json + ")"
        }
      end

      if current_visitor.has_role?('admin') && material.respond_to?(:materials_collections)
        links[:assign_collection] = {
          text: "Add to Collection",
          target: "_blank",
          url: collections_external_activity_path(material)
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
