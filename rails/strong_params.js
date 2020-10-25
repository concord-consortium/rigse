#!/usr/bin/env node

/*

  This script was created to aid in the strong parameters update work for the Rails 4 migration

  Using a list of models and attributes generated in the rails console this script searches for mass assignment methods in all the ruby code.

  Currently the result of that search is written out as a json file.

  TODO:

  1. Add code to check if "strong_params(" is found on new/create/update line (can use "# no strong_params() needed here" to skip line)
  2. Add code to generate strong_params method as string
  3. Add code to inject strong_params method into file at right spot (in class in controller vs at end of fle in spec, etc)
  4. Add code to inject test for strong_params in controller specs
  4. Add code to inject strong_params() wrapper

*/

const fs = require("fs")
const path = require("path")

// list generated in rails console using:
// ActiveRecord::Base.descendants.map { |m| puts "#{m.name};#{m.name.underscore}.rb;#{m.attribute_names.map { |a| a.to_sym }}" }
const railsConsoleModelInfo = [
  "User;user.rb;[:id, :login, :first_name, :last_name, :email, :encrypted_password, :password_salt, :remember_token, :confirmation_token, :state, :remember_created_at, :confirmed_at, :deleted_at, :uuid, :created_at, :updated_at, :default_user, :site_admin, :external_id, :require_password_reset, :of_consenting_age, :have_consent, :asked_age, :reset_password_token, :sign_in_count, :current_sign_in_at, :last_sign_in_at, :current_sign_in_ip, :last_sign_in_ip, :unconfirmed_email, :confirmation_sent_at, :require_portal_user_type, :sign_up_path, :email_subscribed, :can_add_teachers_to_cohorts]",
  "HABTM_Roles;habtm_roles.rb;[:role_id, :user_id]",
  "ExternalActivity;external_activity.rb;[:id, :user_id, :uuid, :name, :archived_description, :url, :publication_status, :created_at, :updated_at, :offerings_count, :save_path, :append_learner_id_to_url, :popup, :append_survey_monkey_uid, :template_id, :template_type, :launch_url, :is_official, :student_report_enabled, :teacher_guide_url, :thumbnail_url, :is_featured, :has_pretest, :short_description, :allow_collaboration, :author_email, :is_locked, :logging, :is_assessment_item, :author_url, :print_url, :is_archived, :archive_date, :credits, :license_code, :append_auth_token, :enable_sharing, :material_type, :rubric_url, :saves_student_data, :long_description_for_teacher, :long_description, :keywords, :tool_id, :has_teacher_edition, :teacher_resources_url]",
  "Admin::Cohort;admin/cohort.rb;[:id, :project_id, :name, :email_notifications_enabled]",
  "Admin::Project;admin/project.rb;[:id, :name, :created_at, :updated_at, :landing_page_slug, :landing_page_content, :project_card_image_url, :project_card_description, :public]",
  "Interactive;interactive.rb;[:id, :name, :description, :url, :width, :height, :scale, :image_url, :user_id, :credits, :publication_status, :created_at, :updated_at, :full_window, :no_snapshots, :save_interactive_state, :license_code, :external_activity_id]",
  "AccessGrant;access_grant.rb;[:id, :code, :access_token, :refresh_token, :access_token_expires_at, :user_id, :client_id, :state, :created_at, :updated_at, :learner_id, :teacher_id]",
  "Activity;activity.rb;[:id, :user_id, :uuid, :name, :description, :created_at, :updated_at, :position, :investigation_id, :original_id, :teacher_only, :publication_status, :offerings_count, :student_report_enabled, :show_score, :teacher_guide_url, :thumbnail_url, :is_featured, :is_assessment_item]",
  "Embeddable::MultipleChoice;embeddable/multiple_choice.rb;[:id, :user_id, :uuid, :name, :description, :prompt, :created_at, :updated_at, :enable_rationale, :rationale_prompt, :allow_multiple_selection, :external_id, :is_required, :show_in_featured_question_report]",
  "Embeddable::Iframe;embeddable/iframe.rb;[:id, :user_id, :uuid, :name, :description, :width, :height, :url, :external_id, :created_at, :updated_at, :display_in_iframe, :is_required, :show_in_featured_question_report]",
  "Embeddable::OpenResponse;embeddable/open_response.rb;[:id, :user_id, :uuid, :name, :description, :prompt, :default_response, :created_at, :updated_at, :rows, :columns, :font_size, :external_id, :is_required, :show_in_featured_question_report]",
  "Embeddable::ImageQuestion;embeddable/image_question.rb;[:id, :user_id, :uuid, :name, :prompt, :created_at, :updated_at, :external_id, :drawing_prompt, :is_required, :show_in_featured_question_report]",
  "Admin::AuthoringSite;admin/authoring_site.rb;[:id, :name, :url, :created_at, :updated_at]",
  "Admin::CohortItem;admin/cohort_item.rb;[:id, :admin_cohort_id, :item_id, :item_type]",
  "Admin::NoticeUserDisplayStatus;admin/notice_user_display_status.rb;[:id, :user_id, :last_collapsed_at_time, :collapsed_status]",
  "Admin::ProjectLink;admin/project_link.rb;[:id, :project_id, :name, :href, :created_at, :updated_at, :link_id, :pop_out, :position]",
  "Admin::ProjectMaterial;admin/project_material.rb;[:id, :project_id, :material_id, :material_type, :created_at, :updated_at]",
  "Admin::ProjectUser;admin/project_user.rb;[:id, :project_id, :user_id, :is_admin, :is_researcher]",
  "Admin::Settings;admin/settings.rb;[:id, :user_id, :description, :uuid, :created_at, :updated_at, :home_page_content, :use_student_security_questions, :allow_default_class, :enable_grade_levels, :use_bitmap_snapshots, :teachers_can_author, :enable_member_registration, :allow_adhoc_schools, :require_user_consent, :use_periodic_bundle_uploading, :jnlp_cdn_hostname, :active, :external_url, :custom_help_page_html, :help_type, :include_external_activities, :enabled_bookmark_types, :pub_interval, :anonymous_can_browse_materials, :jnlp_url, :show_collections_menu, :auto_set_teachers_as_authors, :default_cohort_id, :wrap_home_page_content, :custom_search_path, :teacher_home_path, :about_page_content]",
  "Admin::SiteNotice;admin/site_notice.rb;[:id, :notice_html, :created_at, :updated_at, :created_by, :updated_by]",
  "Admin::SiteNoticeUser;admin/site_notice_user.rb;[:id, :notice_id, :user_id, :notice_dismissed, :created_at, :updated_at]",
  "Admin::Tag;admin/tag.rb;[:id, :scope, :tag, :created_at, :updated_at]",
  "Authentication;authentication.rb;[:id, :user_id, :provider, :uid, :created_at, :updated_at]",
  "Client;client.rb;[:id, :name, :app_id, :app_secret, :created_at, :updated_at, :site_url, :domain_matchers, :client_type, :redirect_uris]",
  "CommonsLicense;commons_license.rb;[:code, :name, :description, :deed, :legal, :image, :number, :created_at, :updated_at]",
  "Dataservice::Blob;dataservice/blob.rb;[:id, :content, :token, :bundle_content_id, :created_at, :updated_at, :periodic_bundle_content_id, :uuid, :mimetype, :file_extension, :learner_id, :checksum]",
  "Dataservice::BucketContent;dataservice/bucket_content.rb;[:id, :bucket_logger_id, :body, :processed, :empty, :created_at, :updated_at]",
  "Dataservice::BucketLogItem;dataservice/bucket_log_item.rb;[:id, :content, :bucket_logger_id, :created_at, :updated_at]",
  "Dataservice::BucketLogger;dataservice/bucket_logger.rb;[:id, :learner_id, :created_at, :updated_at, :name]",
  "Dataservice::BundleContent;dataservice/bundle_content.rb;[:id, :bundle_logger_id, :position, :body, :created_at, :updated_at, :otml, :processed, :valid_xml, :empty, :uuid, :original_body, :upload_time, :collaboration_id]",
  "Dataservice::BundleLogger;dataservice/bundle_logger.rb;[:id, :created_at, :updated_at, :in_progress_bundle_id]",
  "Dataservice::ConsoleContent;dataservice/console_content.rb;[:id, :console_logger_id, :position, :body, :created_at, :updated_at]",
  "Dataservice::ConsoleLogger;dataservice/console_logger.rb;[:id, :created_at, :updated_at]",
  "Dataservice::JnlpSession;dataservice/jnlp_session.rb;[:id, :token, :user_id, :access_count, :created_at, :updated_at]",
  "Dataservice::LaunchProcessEvent;dataservice/launch_process_event.rb;[:id, :event_type, :event_details, :bundle_content_id, :created_at, :updated_at]",
  "Dataservice::PeriodicBundleContent;dataservice/periodic_bundle_content.rb;[:id, :periodic_bundle_logger_id, :body, :processed, :valid_xml, :empty, :uuid, :created_at, :updated_at, :parts_extracted]",
  "Dataservice::PeriodicBundleLogger;dataservice/periodic_bundle_logger.rb;[:id, :learner_id, :imports, :created_at, :updated_at]",
  "Dataservice::PeriodicBundlePart;dataservice/periodic_bundle_part.rb;[:id, :periodic_bundle_logger_id, :delta, :key, :value, :created_at, :updated_at]",
  "Embeddable::Embeddable;embeddable/embeddable.rb;[]",
  "Embeddable::MultipleChoiceChoice;embeddable/multiple_choice_choice.rb;[:id, :choice, :multiple_choice_id, :created_at, :updated_at, :is_correct, :external_id]",
  "ExternalActivityReport;external_activity_report.rb;[:external_activity_id, :external_report_id]",
  "ExternalReport;external_report.rb;[:id, :url, :name, :launch_text, :client_id, :created_at, :updated_at, :report_type, :allowed_for_students, :default_report_for_source_type, :individual_student_reportable, :individual_activity_reportable, :move_students_api_url, :move_students_api_token]",
  "Favorite;favorite.rb;[:id, :user_id, :favoritable_id, :favoritable_type, :created_at, :updated_at]",
  "FirebaseApp;firebase_app.rb;[:id, :name, :client_email, :private_key, :created_at, :updated_at]",
  "Image;image.rb;[:id, :user_id, :name, :attribution, :publication_status, :created_at, :updated_at, :image_file_name, :image_content_type, :image_file_size, :image_updated_at, :license_code, :width, :height]",
  "Import::DuplicateUser;import/duplicate_user.rb;[:id, :login, :email, :duplicate_by, :data, :user_id, :import_id]",
  "Import::Import;import/import.rb;[:id, :job_id, :job_finished_at, :import_type, :progress, :total_imports, :user_id, :upload_data, :created_at, :updated_at, :import_data]",
  "Import::ImportedUser;import/imported_user.rb;[:id, :user_url, :is_verified, :user_id, :importing_domain, :import_id]",
  "Import::SchoolDistrictMapping;import/school_district_mapping.rb;[:id, :district_id, :import_district_uuid]",
  "Import::UserSchoolMapping;import/user_school_mapping.rb;[:id, :school_id, :import_school_url]",
  "Investigation;investigation.rb;[:id, :user_id, :uuid, :name, :description, :created_at, :updated_at, :teacher_only, :publication_status, :offerings_count, :student_report_enabled, :allow_activity_assignment, :show_score, :teacher_guide_url, :thumbnail_url, :is_featured, :abstract, :author_email, :is_assessment_item]",
  "LearnerProcessingEvent;learner_processing_event.rb;[:id, :learner_id, :portal_end, :portal_start, :lara_end, :lara_start, :elapsed_seconds, :duration, :login, :teacher, :url, :created_at, :updated_at, :lara_duration, :portal_duration]",
  "Portal::Learner;portal/learner.rb;[:id, :uuid, :student_id, :offering_id, :created_at, :updated_at, :bundle_logger_id, :console_logger_id, :secure_key]",
  "MaterialsCollection;materials_collection.rb;[:id, :name, :description, :project_id, :created_at, :updated_at]",
  "MaterialsCollectionItem;materials_collection_item.rb;[:id, :materials_collection_id, :material_type, :material_id, :position, :created_at, :updated_at]",
  "Page;page.rb;[:id, :user_id, :section_id, :uuid, :name, :description, :position, :created_at, :updated_at, :teacher_only, :publication_status, :offerings_count, :url]",
  "PageElement;page_element.rb;[:id, :page_id, :embeddable_id, :embeddable_type, :position, :created_at, :updated_at, :user_id]",
  "Password;password.rb;[:id, :user_id, :reset_code, :expiration_date, :created_at, :updated_at]",
  "Portal::Bookmark;portal/bookmark.rb;[:id, :name, :type, :url, :user_id, :created_at, :updated_at, :position, :clazz_id, :is_visible]",
  "Portal::BookmarkVisit;portal/bookmark_visit.rb;[:id, :user_id, :bookmark_id, :created_at, :updated_at]",
  "Portal::Clazz;portal/clazz.rb;[:id, :uuid, :name, :description, :start_time, :end_time, :class_word, :status, :course_id, :semester_id, :teacher_id, :created_at, :updated_at, :section, :default_class, :logging, :class_hash]",
  "Portal::Collaboration;portal/collaboration.rb;[:id, :owner_id, :created_at, :updated_at, :offering_id]",
  "Portal::CollaborationMembership;portal/collaboration_membership.rb;[:id, :collaboration_id, :student_id, :created_at, :updated_at]",
  "Portal::Country;portal/country.rb;[:id, :name, :formal_name, :capital, :two_letter, :three_letter, :tld, :iso_id, :created_at, :updated_at]",
  "Portal::Course;portal/course.rb;[:id, :uuid, :name, :description, :school_id, :status, :created_at, :updated_at, :course_number]",
  "Portal::District;portal/district.rb;[:id, :uuid, :name, :description, :created_at, :updated_at, :nces_district_id, :state, :leaid, :zipcode]",
  "Portal::Grade;portal/grade.rb;[:id, :name, :description, :position, :uuid, :active, :created_at, :updated_at]",
  "Portal::GradeLevel;portal/grade_level.rb;[:id, :uuid, :name, :description, :created_at, :updated_at, :has_grade_levels_id, :has_grade_levels_type, :grade_id]",
  "Portal::LearnerActivityFeedback;portal/learner_activity_feedback.rb;[:id, :text_feedback, :score, :has_been_reviewed, :portal_learner_id, :activity_feedback_id, :created_at, :updated_at, :rubric_feedback]",
  "Portal::LegacyCollaboration;portal/legacy_collaboration.rb;[:id, :bundle_content_id, :student_id, :created_at, :updated_at]",
  "Portal::Nces06District;portal/nces06_district.rb;[:id, :LEAID, :FIPST, :STID, :NAME, :PHONE, :MSTREE, :MCITY, :MSTATE, :MZIP, :MZIP4, :LSTREE, :LCITY, :LSTATE, :LZIP, :LZIP4, :KIND, :UNION, :CONUM, :CONAME, :CSA, :CBSA, :METMIC, :MSC, :ULOCAL, :CDCODE, :LATCOD, :LONCOD, :BOUND, :GSLO, :GSHI, :AGCHRT, :SCH, :TEACH, :UG, :PK12, :MEMBER, :MIGRNT, :SPECED, :ELL, :PKTCH, :KGTCH, :ELMTCH, :SECTCH, :UGTCH, :TOTTCH, :AIDES, :CORSUP, :ELMGUI, :SECGUI, :TOTGUI, :LIBSPE, :LIBSUP, :LEAADM, :LEASUP, :SCHADM, :SCHSUP, :STUSUP, :OTHSUP, :IGSLO, :IGSHI, :ISCH, :ITEACH, :IUG, :IPK12, :IMEMB, :IMIGRN, :ISPEC, :IELL, :IPKTCH, :IKGTCH, :IELTCH, :ISETCH, :IUGTCH, :ITOTCH, :IAIDES, :ICOSUP, :IELGUI, :ISEGUI, :ITOGUI, :ILISPE, :ILISUP, :ILEADM, :ILESUP, :ISCADM, :ISCSUP, :ISTSUP, :IOTSUP]",
  "Portal::Nces06School;portal/nces06_school.rb;[:id, :nces_district_id, :NCESSCH, :FIPST, :LEAID, :SCHNO, :STID, :SEASCH, :LEANM, :SCHNAM, :PHONE, :MSTREE, :MCITY, :MSTATE, :MZIP, :MZIP4, :LSTREE, :LCITY, :LSTATE, :LZIP, :LZIP4, :KIND, :STATUS, :ULOCAL, :LATCOD, :LONCOD, :CDCODE, :CONUM, :CONAME, :FTE, :GSLO, :GSHI, :LEVEL, :TITLEI, :STITLI, :MAGNET, :CHARTR, :SHARED, :FRELCH, :REDLCH, :TOTFRL, :MIGRNT, :PK, :AMPKM, :AMPKF, :AMPKU, :ASPKM, :ASPKF, :ASPKU, :HIPKM, :HIPKF, :HIPKU, :BLPKM, :BLPKF, :BLPKU, :WHPKM, :WHPKF, :WHPKU, :KG, :AMKGM, :AMKGF, :AMKGU, :ASKGM, :ASKGF, :ASKGU, :HIKGM, :HIKGF, :HIKGU, :BLKGM, :BLKGF, :BLKGU, :WHKGM, :WHKGF, :WHKGU, :G01, :AM01M, :AM01F, :AM01U, :AS01M, :AS01F, :AS01U, :HI01M, :HI01F, :HI01U, :BL01M, :BL01F, :BL01U, :WH01M, :WH01F, :WH01U, :G02, :AM02M, :AM02F, :AM02U, :AS02M, :AS02F, :AS02U, :HI02M, :HI02F, :HI02U, :BL02M, :BL02F, :BL02U, :WH02M, :WH02F, :WH02U, :G03, :AM03M, :AM03F, :AM03U, :AS03M, :AS03F, :AS03U, :HI03M, :HI03F, :HI03U, :BL03M, :BL03F, :BL03U, :WH03M, :WH03F, :WH03U, :G04, :AM04M, :AM04F, :AM04U, :AS04M, :AS04F, :AS04U, :HI04M, :HI04F, :HI04U, :BL04M, :BL04F, :BL04U, :WH04M, :WH04F, :WH04U, :G05, :AM05M, :AM05F, :AM05U, :AS05M, :AS05F, :AS05U, :HI05M, :HI05F, :HI05U, :BL05M, :BL05F, :BL05U, :WH05M, :WH05F, :WH05U, :G06, :AM06M, :AM06F, :AM06U, :AS06M, :AS06F, :AS06U, :HI06M, :HI06F, :HI06U, :BL06M, :BL06F, :BL06U, :WH06M, :WH06F, :WH06U, :G07, :AM07M, :AM07F, :AM07U, :AS07M, :AS07F, :AS07U, :HI07M, :HI07F, :HI07U, :BL07M, :BL07F, :BL07U, :WH07M, :WH07F, :WH07U, :G08, :AM08M, :AM08F, :AM08U, :AS08M, :AS08F, :AS08U, :HI08M, :HI08F, :HI08U, :BL08M, :BL08F, :BL08U, :WH08M, :WH08F, :WH08U, :G09, :AM09M, :AM09F, :AM09U, :AS09M, :AS09F, :AS09U, :HI09M, :HI09F, :HI09U, :BL09M, :BL09F, :BL09U, :WH09M, :WH09F, :WH09U, :G10, :AM10M, :AM10F, :AM10U, :AS10M, :AS10F, :AS10U, :HI10M, :HI10F, :HI10U, :BL10M, :BL10F, :BL10U, :WH10M, :WH10F, :WH10U, :G11, :AM11M, :AM11F, :AM11U, :AS11M, :AS11F, :AS11U, :HI11M, :HI11F, :HI11U, :BL11M, :BL11F, :BL11U, :WH11M, :WH11F, :WH11U, :G12, :AM12M, :AM12F, :AM12U, :AS12M, :AS12F, :AS12U, :HI12M, :HI12F, :HI12U, :BL12M, :BL12F, :BL12U, :WH12M, :WH12F, :WH12U, :UG, :AMUGM, :AMUGF, :AMUGU, :ASUGM, :ASUGF, :ASUGU, :HIUGM, :HIUGF, :HIUGU, :BLUGM, :BLUGF, :BLUGU, :WHUGM, :WHUGF, :WHUGU, :MEMBER, :AM, :AMALM, :AMALF, :AMALU, :ASIAN, :ASALM, :ASALF, :ASALU, :HISP, :HIALM, :HIALF, :HIALU, :BLACK, :BLALM, :BLALF, :BLALU, :WHITE, :WHALM, :WHALF, :WHALU, :TOTETH, :PUPTCH, :TOTGRD, :IFTE, :IGSLO, :IGSHI, :ITITLI, :ISTITL, :IMAGNE, :ICHART, :ISHARE, :IFRELC, :IREDLC, :ITOTFR, :IMIGRN, :IPK, :IAMPKM, :IAMPKF, :IAMPKU, :IASPKM, :IASPKF, :IASPKU, :IHIPKM, :IHIPKF, :IHIPKU, :IBLPKM, :IBLPKF, :IBLPKU, :IWHPKM, :IWHPKF, :IWHPKU, :IKG, :IAMKGM, :IAMKGF, :IAMKGU, :IASKGM, :IASKGF, :IASKGU, :IHIKGM, :IHIKGF, :IHIKGU, :IBLKGM, :IBLKGF, :IBLKGU, :IWHKGM, :IWHKGF, :IWHKGU, :IG01, :IAM01M, :IAM01F, :IAM01U, :IAS01M, :IAS01F, :IAS01U, :IHI01M, :IHI01F, :IHI01U, :IBL01M, :IBL01F, :IBL01U, :IWH01M, :IWH01F, :IWH01U, :IG02, :IAM02M, :IAM02F, :IAM02U, :IAS02M, :IAS02F, :IAS02U, :IHI02M, :IHI02F, :IHI02U, :IBL02M, :IBL02F, :IBL02U, :IWH02M, :IWH02F, :IWH02U, :IG03, :IAM03M, :IAM03F, :IAM03U, :IAS03M, :IAS03F, :IAS03U, :IHI03M, :IHI03F, :IHI03U, :IBL03M, :IBL03F, :IBL03U, :IWH03M, :IWH03F, :IWH03U, :IG04, :IAM04M, :IAM04F, :IAM04U, :IAS04M, :IAS04F, :IAS04U, :IHI04M, :IHI04F, :IHI04U, :IBL04M, :IBL04F, :IBL04U, :IWH04M, :IWH04F, :IWH04U, :IG05, :IAM05M, :IAM05F, :IAM05U, :IAS05M, :IAS05F, :IAS05U, :IHI05M, :IHI05F, :IHI05U, :IBL05M, :IBL05F, :IBL05U, :IWH05M, :IWH05F, :IWH05U, :IG06, :IAM06M, :IAM06F, :IAM06U, :IAS06M, :IAS06F, :IAS06U, :IHI06M, :IHI06F, :IHI06U, :IBL06M, :IBL06F, :IBL06U, :IWH06M, :IWH06F, :IWH06U, :IG07, :IAM07M, :IAM07F, :IAM07U, :IAS07M, :IAS07F, :IAS07U, :IHI07M, :IHI07F, :IHI07U, :IBL07M, :IBL07F, :IBL07U, :IWH07M, :IWH07F, :IWH07U, :IG08, :IAM08M, :IAM08F, :IAM08U, :IAS08M, :IAS08F, :IAS08U, :IHI08M, :IHI08F, :IHI08U, :IBL08M, :IBL08F, :IBL08U, :IWH08M, :IWH08F, :IWH08U, :IG09, :IAM09M, :IAM09F, :IAM09U, :IAS09M, :IAS09F, :IAS09U, :IHI09M, :IHI09F, :IHI09U, :IBL09M, :IBL09F, :IBL09U, :IWH09M, :IWH09F, :IWH09U, :IG10, :IAM10M, :IAM10F, :IAM10U, :IAS10M, :IAS10F, :IAS10U, :IHI10M, :IHI10F, :IHI10U, :IBL10M, :IBL10F, :IBL10U, :IWH10M, :IWH10F, :IWH10U, :IG11, :IAM11M, :IAM11F, :IAM11U, :IAS11M, :IAS11F, :IAS11U, :IHI11M, :IHI11F, :IHI11U, :IBL11M, :IBL11F, :IBL11U, :IWH11M, :IWH11F, :IWH11U, :IG12, :IAM12M, :IAM12F, :IAM12U, :IAS12M, :IAS12F, :IAS12U, :IHI12M, :IHI12F, :IHI12U, :IBL12M, :IBL12F, :IBL12U, :IWH12M, :IWH12F, :IWH12U, :IUG, :IAMUGM, :IAMUGF, :IAMUGU, :IASUGM, :IASUGF, :IASUGU, :IHIUGM, :IHIUGF, :IHIUGU, :IBLUGM, :IBLUGF, :IBLUGU, :IWHUGM, :IWHUGF, :IWHUGU, :IMEMB, :IAM, :IAMALM, :IAMALF, :IAMALU, :IASIAN, :IASALM, :IASALF, :IASALU, :IHISP, :IHIALM, :IHIALF, :IHIALU, :IBLACK, :IBLALM, :IBLALF, :IBLALU, :IWHITE, :IWHALM, :IWHALF, :IWHALU, :IETH, :IPUTCH, :ITOTGR]",
  "Portal::Offering;portal/offering.rb;[:id, :uuid, :status, :clazz_id, :runnable_id, :runnable_type, :created_at, :updated_at, :active, :default_offering, :position, :anonymous_report, :locked]",
  "Portal::OfferingActivityFeedback;portal/offering_activity_feedback.rb;[:id, :enable_text_feedback, :max_score, :score_type, :activity_id, :portal_offering_id, :created_at, :updated_at, :use_rubric, :rubric]",
  "Portal::OfferingEmbeddableMetadata;portal/offering_embeddable_metadata.rb;[:id, :offering_id, :embeddable_id, :embeddable_type, :enable_score, :max_score, :created_at, :updated_at, :enable_text_feedback]",
  "Portal::PermissionForm;portal/permission_form.rb;[:id, :name, :url, :created_at, :updated_at, :project_id]",
  "Portal::School;portal/school.rb;[:id, :uuid, :name, :description, :district_id, :created_at, :updated_at, :nces_school_id, :state, :zipcode, :ncessch, :country_id, :city]",
  "Portal::SchoolMembership;portal/school_membership.rb;[:id, :uuid, :name, :description, :start_time, :end_time, :member_id, :member_type, :school_id, :created_at, :updated_at]",
  "Portal::Student;portal/student.rb;[:id, :uuid, :user_id, :grade_level_id, :created_at, :updated_at]",
  "Portal::StudentClazz;portal/student_clazz.rb;[:id, :uuid, :name, :description, :start_time, :end_time, :clazz_id, :student_id, :created_at, :updated_at]",
  "Portal::StudentPermissionForm;portal/student_permission_form.rb;[:id, :signed, :portal_student_id, :portal_permission_form_id, :created_at, :updated_at]",
  "Portal::Subject;portal/subject.rb;[:id, :uuid, :name, :description, :teacher_id, :created_at, :updated_at]",
  "Portal::Teacher;portal/teacher.rb;[:id, :uuid, :user_id, :created_at, :updated_at, :offerings_count, :left_pane_submenu_item]",
  "Portal::TeacherClazz;portal/teacher_clazz.rb;[:id, :uuid, :name, :description, :start_time, :end_time, :clazz_id, :teacher_id, :created_at, :updated_at, :active, :position]",
  "Portal::TeacherFullStatus;portal/teacher_full_status.rb;[:id, :offering_id, :teacher_id, :offering_collapsed]",
  "Report::EmbeddableFilter;report/embeddable_filter.rb;[:id, :offering_id, :embeddables, :created_at, :updated_at, :ignore]",
  "Report::Learner;report/learner.rb;[:id, :learner_id, :student_id, :user_id, :offering_id, :class_id, :last_run, :last_report, :offering_name, :teachers_name, :student_name, :username, :school_name, :class_name, :runnable_id, :runnable_name, :school_id, :num_answerables, :num_answered, :num_correct, :answers, :runnable_type, :complete_percent, :permission_forms, :num_submitted, :teachers_district, :teachers_state, :teachers_email, :permission_forms_id, :teachers_id, :teachers_map, :permission_forms_map]",
  "Report::LearnerActivity;report/learner_activity.rb;[:id, :learner_id, :activity_id, :complete_percent]",
  "Role;role.rb;[:id, :title, :position, :uuid]",
  "HABTM_Users;habtm_users.rb;[:role_id, :user_id]",
  "Saveable::ExternalLink;saveable/external_link.rb;[:id, :embeddable_id, :embeddable_type, :learner_id, :offering_id, :response_count, :created_at, :updated_at]",
  "Saveable::ExternalLinkUrl;saveable/external_link_url.rb;[:id, :external_link_id, :bundle_content_id, :position, :url, :is_final, :created_at, :updated_at, :feedback, :has_been_reviewed, :score]",
  "Saveable::ImageQuestion;saveable/image_question.rb;[:id, :learner_id, :offering_id, :image_question_id, :response_count, :created_at, :updated_at, :uuid]",
  "Saveable::ImageQuestionAnswer;saveable/image_question_answer.rb;[:id, :image_question_id, :bundle_content_id, :blob_id, :position, :created_at, :updated_at, :note, :uuid, :is_final, :feedback, :has_been_reviewed, :score]",
  "Saveable::Interactive;saveable/interactive.rb;[:id, :learner_id, :offering_id, :response_count, :created_at, :updated_at, :iframe_id]",
  "Saveable::InteractiveState;saveable/interactive_state.rb;[:id, :interactive_id, :bundle_content_id, :position, :state, :is_final, :feedback, :has_been_reviewed, :score, :created_at, :updated_at]",
  "Saveable::MultipleChoice;saveable/multiple_choice.rb;[:id, :learner_id, :multiple_choice_id, :created_at, :updated_at, :offering_id, :response_count, :uuid]",
  "Saveable::MultipleChoiceAnswer;saveable/multiple_choice_answer.rb;[:id, :multiple_choice_id, :bundle_content_id, :position, :created_at, :updated_at, :uuid, :is_final, :feedback, :has_been_reviewed, :score]",
  "Saveable::MultipleChoiceRationaleChoice;saveable/multiple_choice_rationale_choice.rb;[:id, :choice_id, :answer_id, :rationale, :created_at, :updated_at, :uuid]",
  "Saveable::OpenResponse;saveable/open_response.rb;[:id, :learner_id, :open_response_id, :created_at, :updated_at, :offering_id, :response_count]",
  "Saveable::OpenResponseAnswer;saveable/open_response_answer.rb;[:id, :open_response_id, :bundle_content_id, :position, :answer, :created_at, :updated_at, :is_final, :feedback, :has_been_reviewed, :score]",
  "Saveable::Sparks::MeasuringResistance;saveable/sparks/measuring_resistance.rb;[:id, :learner_id, :created_at, :updated_at, :offering_id]",
  "Saveable::Sparks::MeasuringResistanceReports;saveable/sparks/measuring_resistance_reports.rb;[:id, :measuring_resistance_id, :position, :content, :created_at, :updated_at]",
  "Section;section.rb;[:id, :user_id, :activity_id, :uuid, :name, :description, :position, :created_at, :updated_at, :teacher_only, :publication_status]",
  "SecurityQuestion;security_question.rb;[:id, :user_id, :question, :answer]",
  "StandardDocument;standard_document.rb;[:id, :uri, :jurisdiction, :title, :name, :created_at, :updated_at]",
  "StandardStatement;standard_statement.rb;[:id, :uri, :doc, :statement_notation, :statement_label, :description, :parents, :material_type, :material_id, :created_at, :updated_at, :education_level, :is_leaf]",
  "TeacherProjectView;teacher_project_view.rb;[:id, :viewed_project_id, :teacher_id, :created_at, :updated_at]",
  "Tool;tool.rb;[:id, :name, :source_type, :tool_id]",
  "Portal::GenericBookmark;portal/generic_bookmark.rb;[:id, :name, :type, :url, :user_id, :created_at, :updated_at, :position, :clazz_id, :is_visible]",
];
railsConsoleModelInfo.sort()

// load all the ruby files in memory
const getAllFiles = (dirPath, files) => {
  files = files || {}
  fs.readdirSync(dirPath).forEach((file) => {
    if (fs.statSync(dirPath + "/" + file).isDirectory()) {
      files = getAllFiles(dirPath + "/" + file, files)
    } else if (path.extname(file) == ".rb") {
      const relativePath = path.relative(__dirname, path.join(dirPath, "/", file))
      const lines = fs.readFileSync(relativePath).toString().split("\n")
      files[relativePath] = {lines}
    }
  })
  return files
}
const files = getAllFiles(__dirname)

// check each model against each ruby file line
const models = []
const updateCheck = /\.\s*update_attributes!?\s*\(/
const attrBrackets = /\[|\]/g
const attrFilter = /:id|:created_at|:updated_at/
const attrAccessibleCheck = /attr_accessible/
railsConsoleModelInfo.map((consoleModelInfo) => {
  const [modelName, modelPath, attrArray] = consoleModelInfo.split(";")
  const newOrCreateCheck = new RegExp(`\\b${modelName}\\s*.\\s*(new|create!?)\\s*\\(`)
  const modelInfo = {
    name: modelName,
    path: `app/models/${modelPath}`,
    attrs: attrArray.replace(attrBrackets, "").split(", ").filter((attr) => !attr.match(attrFilter)).join(", "),
    hasAttrAccessible: false,
    newOrCreates: [],
    updates: []
  }
  models.push(modelInfo)

  Object.keys(files).map((relativePath) => {
    const file = files[relativePath]
    file.lines.map((line, lineNumber) => {
      if (line.match(newOrCreateCheck)) {
        modelInfo.newOrCreates.push({file: relativePath, lineNumber, line: line.trim()})
      }
    })
  })
  modelInfo.newOrCreates.map((newOrCreate) => {
    const file = files[newOrCreate.file]
    file.lines.map((line, lineNumber) => {
      if (line.match(updateCheck)) {
        modelInfo.updates.push({file: newOrCreate.file, lineNumber, line: line.trim()})
      }
    })
  })

  const file = files[modelInfo.path]
  if (file) {
    file.lines.map((line, lineNumber) => {
      if (line.match(attrAccessibleCheck)) {
        modelInfo.hasAttrAccessible = true
      }
    })
  }
})


const stats = {
  numModels: models.length,
  hasAttrAccessible: 0,
  newOrCreates: {
    all: 0,
    inControllers: 0,
    outsideControllers: 0
  },
  updates: {
    all: 0,
    inControllers: 0,
    outsideControllers: 0
  },
}
models.forEach((model) => {
  stats.newOrCreates.all += model.newOrCreates.length
  if (model.hasAttrAccessible) {
    stats.hasAttrAccessible++
  }
  model.newOrCreates.map((newOrCreate) => {
    const isController = newOrCreate.file.indexOf("_controller.rb") !== -1
    stats.newOrCreates[isController ? "inControllers" : "outsideControllers"]++
  })
  model.updates.map((update) => {
    const isController = update.file.indexOf("_controller.rb") !== -1
    stats.updates[isController ? "inControllers" : "outsideControllers"]++
  })
})

fs.writeFileSync("strong_params_output.json", JSON.stringify({stats, models}, null, 2))
