fs = require 'fs'

files = """
  access_grant.rb
  activity.rb
  attached_file.rb
  authentication.rb
  author_note.rb
  client.rb
  commons_license.rb
  dataservice.rb
  formatted_doc.rb
  image.rb
  installer_report.rb
  interactive.rb
  investigation.rb
  investigation_observer.rb
  learner_detail.rb
  materials_collection.rb
  materials_collection_item.rb
  page.rb
  page_element.rb
  password.rb
  password_mailer.rb
  resource_page.rb
  role.rb
  search.rb
  section.rb
  security_question.rb
  setting.rb
  student_roster.rb
  student_roster_row.rb
  student_view.rb
  teacher_note.rb
  user.rb
  user_mailer.rb
  user_observer.rb
  admin/notice_user_display_status.rb
  admin/project.rb
  admin/project_link.rb
  admin/project_material.rb
  admin/project_user.rb
  admin/settings.rb
  admin/settings_observer.rb
  admin/settings_vendor_interface.rb
  admin/site_notice.rb
  admin/site_notice_role.rb
  admin/site_notice_user.rb
  admin/tag.rb
  api/v1/school_registration.rb
  api/v1/student_registration.rb
  api/v1/teacher_registration.rb
  api/v1/user_registration.rb
  dataservice/blob.rb
  dataservice/bucket_content.rb
  dataservice/bucket_logger.rb
  dataservice/bucket_log_item.rb
  dataservice/bundle_content.rb
  dataservice/bundle_content_observer.rb
  dataservice/bundle_logger.rb
  dataservice/console_content.rb
  dataservice/console_logger.rb
  dataservice/jnlp_session.rb
  dataservice/launch_process_event.rb
  dataservice/periodic_bundle_content.rb
  dataservice/periodic_bundle_content_observer.rb
  dataservice/periodic_bundle_logger.rb
  dataservice/periodic_bundle_part.rb
  dataservice/process_bundle_job.rb
  dataservice/process_external_activity_data_job.rb
  embeddable/biologica/breed_offspring.rb
  embeddable/biologica/chromosome.rb
  embeddable/biologica/chromosome_zoom.rb
  embeddable/biologica/meiosis_view.rb
  embeddable/biologica/multiple_organism.rb
  embeddable/biologica/organism.rb
  embeddable/biologica/pedigree.rb
  embeddable/biologica/static_organism.rb
  embeddable/biologica/world.rb
  embeddable/data_collector.rb
  embeddable/data_table.rb
  embeddable/drawing_tool.rb
  embeddable/embeddable.rb
  embeddable/iframe.rb
  embeddable/image_question.rb
  embeddable/inner_page.rb
  embeddable/inner_page_page.rb
  embeddable/lab_book_snapshot.rb
  embeddable/multiple_choice.rb
  embeddable/multiple_choice_choice.rb
  embeddable/mw_modeler_page.rb
  embeddable/n_logo_model.rb
  embeddable/open_response.rb
  embeddable/raw_otml.rb
  embeddable/smartgraph/range_question.rb
  embeddable/sound_grapher.rb
  embeddable/video_player.rb
  embeddable/xhtml.rb
  external_activity.rb
  import/duplicate_user.rb
  import/import.rb
  import/imported_user.rb
  import/import_external_activity.rb
  import/import_schools_and_districts.rb
  import/import_users.rb
  import/school_district_mapping.rb
  import/user_school_mapping.rb
  otrunk_example/otml_category.rb
  otrunk_example/otml_file.rb
  otrunk_example/otrunk_import.rb
  otrunk_example/otrunk_view_entry.rb
  portal/bookmark.rb
  portal/bookmark_visit.rb
  portal/clazz.rb
  portal/collaboration.rb
  portal/collaboration_membership.rb
  portal/country.rb
  portal/course.rb
  portal/district.rb
  portal/generic_bookmark.rb
  portal/grade.rb
  portal/grade_level.rb
  portal/learner.rb
  portal/legacy_collaboration.rb
  portal/nces06_district.rb
  portal/nces06_school.rb
  portal/offering.rb
  portal/padlet_bookmark.rb
  portal/permission_form.rb
  portal/school.rb
  portal/school_membership.rb
  portal/school_selector.rb
  portal/semester.rb
  portal/state_or_province.rb
  portal/student.rb
  portal/student_clazz.rb
  portal/student_permission_form.rb
  portal/subject.rb
  portal/teacher.rb
  portal/teacher_clazz.rb
  portal/teacher_full_status.rb
  probe/calibration.rb
  probe/data_filter.rb
  probe/device_config.rb
  probe/physical_unit.rb
  probe/probe_type.rb
  probe/vendor_interface.rb
  report/embeddable_filter.rb
  report/learner/activity.rb
  report/learner/investigation.rb
  report/learner/learner.rb
  report/learner/section.rb
  report/learner/selector.rb
  report/learner.rb
  report/learner_activity.rb
  report/offering/activity.rb
  report/offering/investigation.rb
  report/offering/page.rb
  report/offering/section.rb
  report/offering_status.rb
  report/offering_student_status.rb
  report/util.rb
  report/util_learner.rb
  ri_gse/assessment_target.rb
  ri_gse/assessment_target_unifying_theme.rb
  ri_gse/big_idea.rb
  ri_gse/domain.rb
  ri_gse/expectation.rb
  ri_gse/expectation_indicator.rb
  ri_gse/expectation_stem.rb
  ri_gse/grade_span_expectation.rb
  ri_gse/knowledge_statement.rb
  ri_gse/unifying_theme.rb
  saveable/external_link.rb
  saveable/external_link_url.rb
  saveable/image_question.rb
  saveable/image_question_answer.rb
  saveable/multiple_choice.rb
  saveable/multiple_choice_answer.rb
  saveable/multiple_choice_rationale_choice.rb
  saveable/open_response.rb
  saveable/open_response_answer.rb
  saveable/respondable_proxy.rb
  saveable/saveable.rb
  saveable/saveable_standin.rb
  saveable/sparks/measuring_resistance.rb
  saveable/sparks/measuring_resistance_reports.rb
  search/search_material.rb
""".split '\n'

code = """
  class FooPolicy < ApplicationPolicy
  end
"""

prefix = './app/policies'
for file in files
  [pathParts..., filename] = file.split '/'
  [basename, ext] = filename.split '.'
  className = basename.split('_').map((s) -> s.charAt(0).toUpperCase() + s.slice(1)).join('')
  prevParts = []
  for part in pathParts
    prevParts.push part
    path = "#{prefix}/#{prevParts.join '/'}"
    if not fs.existsSync path
      console.log "Creating path: #{path}"
      fs.mkdirSync path

  path = "#{prefix}/#{pathParts.join '/'}/#{basename}_policy.rb"
  updatedCode = code.replace 'Foo', className
  fs.writeFileSync path, updatedCode



