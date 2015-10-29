fs = require 'fs'
pluralize = require './pluralize'

files = """
activities_controller.rb
application_controller.rb
attached_files_controller.rb
authentications_controller.rb
authoring_controller.rb
author_notes_controller.rb
auth_controller.rb
external_activities_controller.rb
help_controller.rb
home_controller.rb
images_controller.rb
installer_reports_controller.rb
interactives_controller.rb
investigations_controller.rb
materials_collections_controller.rb
misc_controller.rb
misc_metal_controller.rb
pages_controller.rb
page_elements_controller.rb
passwords_controller.rb
registrations_controller.rb
resource_pages_controller.rb
search_controller.rb
sections_controller.rb
security_questions_controller.rb
teacher_notes_controller.rb
users_controller.rb
admin/learner_details_controller.rb
admin/permission_forms_controller.rb
admin/projects_controller.rb
admin/settings_controller.rb
admin/site_notices_controller.rb
admin/tags_controller.rb
api/api_controller.rb
api/v1/collaborations_controller.rb
api/v1/countries_controller.rb
api/v1/districts_controller.rb
api/v1/materials_bin_controller.rb
api/v1/materials_controller.rb
api/v1/schools_controller.rb
api/v1/search_controller.rb
api/v1/security_questions_controller.rb
api/v1/states_controller.rb
api/v1/students_controller.rb
api/v1/teachers_controller.rb
browse/activities_controller.rb
browse/external_activities_controller.rb
browse/investigations_controller.rb
dataservice/blobs_controller.rb
dataservice/bucket_contents_metal_controller.rb
dataservice/bucket_loggers_controller.rb
dataservice/bucket_log_items_metal_controller.rb
dataservice/bundle_contents_controller.rb
dataservice/bundle_contents_metal_controller.rb
dataservice/bundle_loggers_controller.rb
dataservice/console_contents_controller.rb
dataservice/console_contents_metal_controller.rb
dataservice/console_loggers_controller.rb
dataservice/external_activity_data_controller.rb
dataservice/periodic_bundle_contents_metal_controller.rb
dataservice/periodic_bundle_loggers_controller.rb
dataservice/periodic_bundle_loggers_metal_controller.rb
embeddable/biologica/breed_offsprings_controller.rb
embeddable/biologica/chromosomes_controller.rb
embeddable/biologica/chromosome_zooms_controller.rb
embeddable/biologica/meiosis_views_controller.rb
embeddable/biologica/multiple_organisms_controller.rb
embeddable/biologica/organisms_controller.rb
embeddable/biologica/pedigrees_controller.rb
embeddable/biologica/static_organisms_controller.rb
embeddable/biologica/worlds_controller.rb
embeddable/data_collectors_controller.rb
embeddable/data_tables_controller.rb
embeddable/drawing_tools_controller.rb
embeddable/image_questions_controller.rb
embeddable/inner_pages_controller.rb
embeddable/lab_book_snapshots_controller.rb
embeddable/multiple_choices_controller.rb
embeddable/mw_modeler_pages_controller.rb
embeddable/n_logo_models_controller.rb
embeddable/open_responses_controller.rb
embeddable/raw_otmls_controller.rb
embeddable/smartgraph/range_questions_controller.rb
embeddable/sound_graphers_controller.rb
embeddable/video_players_controller.rb
embeddable/xhtmls_controller.rb
import/imported_login_controller.rb
import/imports_controller.rb
otrunk_example/otml_categories_controller.rb
otrunk_example/otml_files_controller.rb
otrunk_example/otrunk_imports_controller.rb
otrunk_example/otrunk_view_entries_controller.rb
portal/bookmarks_controller.rb
portal/clazzes_controller.rb
portal/courses_controller.rb
portal/districts_controller.rb
portal/grades_controller.rb
portal/grade_levels_controller.rb
portal/learners_controller.rb
portal/learner_jnlp_renderer.rb
portal/nces06_districts_controller.rb
portal/nces06_schools_controller.rb
portal/offerings_controller.rb
portal/offerings_metal_controller.rb
portal/schools_controller.rb
portal/school_memberships_controller.rb
portal/school_selector_controller.rb
portal/semesters_controller.rb
portal/students_controller.rb
portal/student_clazzes_controller.rb
portal/subjects_controller.rb
portal/teachers_controller.rb
portal/user_type_selector_controller.rb
probe/calibrations_controller.rb
probe/data_filters_controller.rb
probe/device_configs_controller.rb
probe/physical_units_controller.rb
probe/probe_types_controller.rb
probe/vendor_interfaces_controller.rb
report/learner_controller.rb
ri_gse/assessment_targets_controller.rb
ri_gse/big_ideas_controller.rb
ri_gse/domains_controller.rb
ri_gse/expectations_controller.rb
ri_gse/expectation_stems_controller.rb
ri_gse/grade_span_expectations_controller.rb
ri_gse/knowledge_statements_controller.rb
ri_gse/unifying_themes_controller.rb
saveable/sparks/measuring_resistances_controller.rb
""".split '\n'

trimRegex = /^\s+|\s+$/g
defRegex = /^(\s*)def(\s+)(.+)\s*$/
classRegex = /^(\s*)class(\s+)$/
filterRegex = /^(\s*)(\S+)_filter(\s+)/

makeClassName = (text) -> text.split('_').map((s) -> s.charAt(0).toUpperCase() + s.slice(1)).join('')

prefix = './app/controllers'
for file in files
  console.log file
  [pathParts..., filename] = file.split '/'
  basename = filename.replace('_controller.rb', '')
  instanceVar = pluralize.singular(basename)
  pluralInstanceVar = pluralize.plural(instanceVar)
  className = makeClassName instanceVar
  if pathParts.length > 0
    className = "#{(pathParts.map makeClassName).join '::'}::#{className}"

  path = "#{prefix}/#{file}"
  inPublic = true
  markedFilters = false
  handler =
    classIndex: -1
    privateIndex: -1
    endIndex: -1

  input = (fs.readFileSync path, 'utf8').split '\n'
  output = []
  for line, i in input

    trimmed = line.replace trimRegex, ''
    if trimmed is 'public'
      inPublic = true
    else if trimmed is 'private'
      inPublic = false
      if handler.privateIndex is -1
        handler.privateIndex = i
    else if trimmed is 'protected'
      inPublic = false
    else if not handler.classIndex is -1 and line.match classRegex
      handler.classIndex = i
    else if trimmed is 'end'
      handler.endIndex = i
    else if not markedFilters
      m = line.match filterRegex
      if m
        output.push "#{m[1]}# PUNDIT_CHECK_FILTERS"
        markedFilters = true

    output.push line
    if insertLines?.after is i
      for insertLine in insertLines.lines
        output.push insertLine
      insertLines = null

    if inPublic
      m = line.match defRegex
      if m
        indent = m[1]
        method = m[3]
        review = "#{indent}  # PUNDIT_REVIEW_AUTHORIZE"
        if method.indexOf('index') isnt -1
          output.push review
          output.push "#{indent}  # PUNDIT_CHECK_AUTHORIZE"
          output.push "#{indent}  authorize #{className}"
          reviewScope = "#{indent}  # PUNDIT_REVIEW_SCOPE"
          code = "#{indent}  @#{pluralInstanceVar} = policy_scope(#{className})"
          instanceRegex = new RegExp "^(\\s*)@#{pluralInstanceVar}(\\s*)="
          for nextLine, j in input.slice(i + 1)
            if nextLine.match instanceRegex
              insertLines =
                after: j + i + 1
                lines: [reviewScope, "#{indent}  # PUNDIT_CHECK_SCOPE (found instance)", code]
              break
            else if nextLine.replace(trimRegex, '') is 'end'
              break
          if not insertLines
            output.push reviewScope
            output.push "#{indent}  # PUNDIT_CHECK_SCOPE (did not find instance)"
            output.push code
        else
          switch method
            when 'create', 'new'
              output.push review
              output.push "#{indent}  # PUNDIT_CHECK_AUTHORIZE"
              output.push "#{indent}  authorize #{className}"
            when 'show', 'update', 'edit', 'destroy'
              code = "#{indent}  authorize @#{instanceVar}"
              instanceRegex = new RegExp "^(\\s*)@#{instanceVar}(\\s*)="
              for nextLine, j in input.slice(i + 1)
                if nextLine.match instanceRegex
                  insertLines =
                    after: j + i + 1
                    lines: [review, "#{indent}  # PUNDIT_CHECK_AUTHORIZE (found instance)", code]
                  break
                else if nextLine.replace(trimRegex, '') is 'end'
                  break
              if not insertLines
                output.push review
                output.push "#{indent}  # PUNDIT_CHECK_AUTHORIZE (did not find instance)"
                output.push code
            else
              output.push review
              output.push "#{indent}  # PUNDIT_CHOOSE_AUTHORIZE"
              output.push "#{indent}  # no authorization needed ..."
              output.push "#{indent}  # authorize #{className}"
              output.push "#{indent}  # authorize @#{instanceVar}"
              output.push "#{indent}  # authorize #{className}, :new_or_create?"
              output.push "#{indent}  # authorize @#{instanceVar}, :update_edit_or_destroy?"

  fs.writeFileSync path, output.join('\n')



