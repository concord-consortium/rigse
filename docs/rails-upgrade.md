# Upgrade Steps

This documents the steps taken to upgrade Portal from ruby 2.2.6/rails 3.2.22 to the latest ruby/rails version along with any of the issues found along the way.  This should be a good resource for other project upgrades.

## Finding RJS use in the portal:
* Seach for occurance of: `render :update` and `page <<`
* Search log files for deprecation warnings: `DEPRECATION WARNING: Prototype Usage:`
* Review related efforts by hint:
  [github issues](https://github.com/concord-consortium/rigse/issues?page=2&q=is%3Aissue+is%3Aopen+prototype)
  [hint audit](https://github.com/concord-consortium/rigse/issues/457)
* TODO: Should we add risk / effort to each item on this list?

### Specific Uses:
* lib/clipboard.rb:84 ✅
  * type: link_to_remote
  * solution: remove
* api/site_notices_controller.rb ✅
  * References are not yet found automatically
  * type: page <<
  * solution:
    * Remove use in controller. Response is ignored by react component.
* helpers/js_helper.rb remove_link ✅
  * type: link_to_function
  * solution: remove, simplify admin pages (_materials_in_colleciton)
  * usage:
    * _edit_choice.html.haml apps/views/embeddable/ …
    * _materials_in_collection.html.haml (❌this was a difference reference as far as I can tell)
* helpers/js_helper.rb safe_js ✅
  * type: page <<
  * solution:
    * remove embeddable partials ️️✅
    * update external_activities views ️ℹ️
    * simplify admin pages ✅
    * ℹ️need to check that these solutions are in the right files
  * usage:
    * various view/embeddables/destroy.js.rjs (MC, open response, image Q ....)
    * views/external_activities/create.js.rjs
    * views/portal/clazzes/destroy.js.rjs
    * views/portal/districts/destroy.js.rjs
    * views/portal/schoools/destroy.js.rjs
    * views/portal/student_clazzes/destroy.js.rjs
* student_clazzes_helper.rb student_add_dropdown ✅
  * type: button_to_remote
  * solutions:
    * re-write page using react
    * or do full page refresh of student-roster instead
  * usage:
    * clazzes_controller.rb,
    * students_controller.rb,
    * _form_student_roster.html.haml
    * portal/student_clazzes/destroy.js.rjs
    * _add_edit_list_for_clazz.html.haml
    * _list_for_clazz.html.haml
* portal/teachers_helper.rb teacher_add_dropdown ✅
  * type: button_to_remote
  * solution:
     * re-write pages using react
     * or do full page refresh of student-roster instead
  * usage:
    * app/controllers/protal/clazzes_controller.rb add_teacher
    * app/controllers/protal/clazzes_controller.rb _teacher
    * app/views/partials/_table_for_clazzz_setup.html.haml
* helpers/application_helper.rb wrap_edit_link_around_content ✅
  * type: AJAX_OPTIONS
  * solutions:
    * remove embeddables
    * remove dataservice blob views
    * simplify admin pages
    * convert to editable form fields
  * usage:
    * views/admin/projects/_show.html.haml
    * views/admin/projects/_show_for_managers.html.haml
    * views/admin/settings/_show.html.haml
    * views/admin/tags/_show.html.haml
    * views/dataservice/blobs?_show.html.haml
    * views/embeddables/image_questions|mutiple_choice|open_responses/_show.html.haml
    * views/materials_collections/_show.html.haml
    * views/portal/districts/_show.html.haml
    * views/portal/grades/_show.html.haml
    * views/portal/grade_levelss/_show.html.haml
    * views/portal/schools/_show.html.haml
    * specs
* helpers/application_helper.rb toggle_all ✅
  * type: link_to_function
  * solutions:
    * remove -- only used to hide / show item deets in collection
    * modify the method to do nothing (even hide label)
  * usage:
    * views/interactives/index.html.haml ✅
    * views/shared/_activity_header.haml
    * views/shared/_collection_menu.html.haml
    * views/shared/_page_header.haml
    * views/shared/_section_header.haml
    * views/users/_index ✅
* helpers/application_helper.rb toggle_more ✅
  * type: link_to_function, visual_effect, replace_html
  * solutions:
    * remove this method isn't used except in spec test.
  * usage:
    * rails/spec/helpers/application_helper_spec.rb
* helpers/application_helper.rb remote_link_button ✅
  * type: link_to_remote
  * solutions:
    * simplify admin pages
    * reload full pages when entites are deleted (most common use)
    * remove teacher notes and author notes
    * remove clipboard support
  * usage:
    * app/views/materials_collection/_materials_in_collection.html.haml
    * views/portal/students/_current_student_list_for_clazz.html.haml
    * teachers _list_for_clazz_setup.html.haml
    * teachers _table_for_clazz.html.haml
    * shared _notes_menu.html.haml
    * clipboard.rb
* helpers/application_helper.rb function_link_button ✅
  * type: link_to_function
  * solutions:
    * can delete this and its test
  * usage:
    * application_helper_spec.rb
* app/views/teacher_notes ✅
  * type: AJAX_OPTIONS, visual_effect, link_to_function
  * usage: not used really
  * solutions: remove teacher_notes completely
* app/views/shared/_accordion_nav.html.haml & ✅
* app/views/shared/_activity_trail.html.haml & ✅
* app/views/shared/_general_accordion_nav.html.haml & ✅
* app/views/shared/_page_header.html.haml & ✅
* app/views/shared/_offering_for_teacher.html.haml & ✅
* app/views/shared/_runnable.html.haml & ✅
* app/views/shared/_runnables_listing.html.haml & ✅
  * for all of the above:
    * type: various
    * solution: remove all of these views
* app/views/search/_material_unassigned_clazzes.html.haml ✅
* app/views/search/_material_unassigned_collections.html.haml ✅
  * for all of the above:
    * type: various
    * solution: Can probably remove these, they should be react components
* app/views/portal/student_clazzes/destroy.js.rjs ✅
  * type: replace_html, replace, remove, page <<
  * usage: class roster page
  * solutions:
    * move class roster functions to new react components
* app/views/portal/offerings/_list_for_clazz.html.haml ✅
  * type: drop_receiving_element
  * usage: none
  * solutions: remove this unused view
* app/views/portal/grade_levels/_remote_form.html.haml ✅
  * type: remote_form_for
  * usage: unknown
  * solution: TBD: where is this used?
* app/views/portal/grades/_remote_form.html.haml ✅
  * type: remote_form_for
  * usage: unknown
  * solution: TBD: where is this used?
* app/views/portal/learners/_remote_form.html.haml ✅
  * type: remote_form_for
  * usage: unknown
  * solution: remove?
* app/views/portal/school_selector/update.rjs ℹ️
  * type: repalce_html
  * usage: unused -- handled by react-components now
  * Solution: remove
  * ℹ️ there is also a partial, and view "model", for this it is used by the teachers controller and school_selector_controller
* app/views/portal/teachers/_list_for_clazz.html.haml ✅
  * type: link_to_remote
  * usage: used by classes/xx/edit (class setup)
  * solution: Make new class setup react components or reload page
* app/views/portal/schools/_remote_form.html.haml ✅
  * type: remote_form_for
   * usage: used by admin interface
   * solutions:
    * simplify admin interface
* app/views/portal/schools/destroy.js.rjs ✅
   * type: page.remove
   * usage: used by admin interface
   * solutions:
    * simplify admin interface
* app/views/portal/students/_register.html.haml ✅
  * type: remote_form_for
  * ~usage: should not be used any more replaced by react~
  * this is currently used by students when they join a new class
    * solution: remove
* app/views/portal/students/_table_for_clazz.html.haml ✅
  * type: link_to_remote
  * usage: used in class roster
    * solutions:
      * move to student roster react component
      * reload full page after clicking delete
      * link to student editing form instead of in-place edits
* app/views/portal/districts/_remote_form.html.ham ✅
  * usage: used by admin interface
  * solution: simplify admin interface
* app/views/portal/clazzes/edit_offerings.html.haml ✅
  * usage: no longer used by class views. React components are used
  * solution:  remove
* app/views/portal/clazzes/destroy.js.rjs ✅
  * usage: no longer used. We don't delete classes any more ?
  * solution: remove
* app/views/portal/bookmarks/_show.html.haml ✅
* app/views/portal/bookmarks/generic_bookmark/_button.html.haml ✅
* app/views/portal/bookmarks/padlet_bookmark/_button.html.haml ✅
  * for all of the above bookmark items:
  * usage: these seem to still be used, and still use RJS
  * solutions:
    * Use simple page reload pattern and CRUD routes.
    * Create a react component.
* app/views/materials_collections/_materials_in_collection.html.haml
* app/views/materials_collections/_remote_form.html.haml ✅
  * ~usage: I believe these are handled by react components now.~
  * usage: this is used by admins to manage collections
  * ~solution: remove~
  * solution: simplify or reactify
* app/views/images/destroy.rjs ✅
* app/views/images/index.html.haml ✅
  * usage: It doesn't look like this page is used anymore: https://learn.staging.concord.org/images
  * solution: delete these, possibly replace with simple CRUD routes
* app/views/home/_notice.html.haml ❌
  * usage: notices use react-components
  * ~solution: remove this~
  * solution: this partial doesn't seem to use any prototype-rails and it is what is rendering the react-components component for the notices so it should stay
* app/views/external_activities/_basic_form.html.haml ✅
  * type: remote_form_for
  * usage:
    * edit it portal-setting (https://learn.staging.concord.org/eresources/1215/edit)
    * edit in material-edit ( https://learn.staging.concord.org/eresources/1215/matedit?iFrame=true )
  * solution: Simplify the forms (most likely in the material-edit lightbox editing view)
* app/views/external_activities/_runnable_list.html.haml ✅
  * type:  draggable_element
  * usage:
    * images_controller.rb
    * teacher page portal/teacher/1
    * old class view page portal/classes/1
  * solution:
    * remove the teacher page (we need to retain the ability to change school)
    * remove the old class view page (portal/classes/1)
* app/views/external_activities/_show.html.haml ✅
  * type: sortable_element
  * usage: not used.
  * solution: remove
* app/views/external_activities/create.js.rjs ✅
  * usage: I dont think this is used. The external activity form uses normal forms
  * solution: remove
* app/views/external_activities/destroy.js.rjs ✅
  * usage: I dont think this is used. The external activity form uses normal forms
  * solution: remove
* app/views/external_activities/index.html.haml ✅
  * type: observe_form
  * usage: old and broken index page:/external_activities
  * solution: remove
* app/views/embeddable/open_responses/_remote_form.html.haml ✅
* app/views/embeddable/open_responses/destroy.js.rjs ✅
* app/views/embeddable/multiple_choices/_remote_form.html.haml ✅
* app/views/embeddable/multiple_choices/add_choice.js.rjs ✅
* app/views/embeddable/multiple_choices/destroy.js.rjs ✅
* app/views/embeddable/image_questions/_remote_form.html.haml ✅
* app/views/embeddable/image_questions/destroy.js.rjs ✅
* app/views/dataservice/blobs/_remote_form.html.haml ✅
* app/views/dataservice/bundle_contents/_remote_form.html.haml ✅
* app/views/dataservice/bundle_loggers/_remote_form.html.haml ✅
* app/views/dataservice/console_contents/_remote_form.html.haml ✅
* app/views/dataservice/console_loggers/_remote_form.html.haml ✅
* app/views/author_notes/_remote_form.html.ham  ✅
* app/views/author_notes/_show.html.haml  ✅
* app/controllers/teacher_notes_controller.rb ✅
  * for all the above:
    * solution: remove
* app/controllers/search_controller.rb
  * type replace_html, page <<
  * usage: Search controller isn't used, replaced by API version
  * solution: remove
* app/controllers/students_controller.rb (create ✅ / confirm ✅)
  * type: replace_html, replace, page <<, visual_effect, remove &etc.
  * usage:
    * used in
      * class roster functions
    * solutions:
      * (note that student registration is handld by the api controllers)
      * simplify roster pages ( portal/classes/136/roster )
      * convert roster to react component
* app/controllers/portal/clazzes_controller.rb add_offering
* app/controllers/portal/clazzes_controller.rb remove_offering
  * type: insert_html, page <<
  * usage:
    * _list_for_class.html.haml  ( used by portal/classes/xxx -- can delete)
    * _edit_offerings.html.haml
  * slution: remove
* app/controllers/portal/clazzes_controller.rb add_student ✅
  * type: replace_html, page <<
  * usage:
    * student roster pages (portal/classes/107/roster) by way of:
    * student_clazzes_helper.rb student_add_dropdown
  * solution:
    * update student roster page (portal/classes/107/roster)
    * https://www.pivotaltracker.com/story/show/174324301
* app/controllers/portal/clazzes_controller.rb add_teacher
  * type: replace_html, page <<, visual_effect
  * usage:
    * teachers_helper.rb teacher_add_dropdown
    * _list_for_clazz.html.haml
  * solution:
    * delete _list_for_clazz.html.haml
    * update teacher_add_dropdown on class setup page (portal/classes/107/edit)
    * https://www.pivotaltracker.com/story/show/174318198
* app/controllers/portal/clazzes_controller.rb remove_teacher
  * type: replace_html, page <<, replace
  * usage:
    * class setup page portal/classes/107/edit
    * _list_for_clazz_setup.html.haml
    * _table_for_clazz.html.haml
  * solution:
    * update the teacher listing for class setup page (portal/classes/107/edit)
    * https://www.pivotaltracker.com/story/show/174318198
* app/controllers/portal/clazzes_controller.rb manage_classes
  * type:
  * usage:
    * manage class page: portal/classes/manage
  * solution:
    * update manage class page: portal/classes/manage
    * https://www.pivotaltracker.com/story/show/174325159
* app/controllers/portal/clazzes_controller.rb add_offering

## Start by looking at older audit done by hint media:

## Misc notes:
* remove teacher page (porta/teachers/##/show), but we need a way to set the teachers school

### Test failures when we remove the prototype-legacy-helper gem:

[link](https://github.com/concord-consortium/rigse/pull/757),

* Spec without webdriver: 57 / 3505 failures
* Spec with webdriver: 12 failures
* Cucumber JS feature failures: 52 / 92
* Cucumber without JS feature failures: 20 / 101
#### 141 Total failing tests
#### Spec Failures

rspec ./spec/controllers/admin/settings_controller_spec.rb:35 # Admin::SettingsController GET index for managers only allows managers to edit the current settings and only shows them the information they can change
rspec ./spec/controllers/api/v1/site_notices_controller_spec.rb:50 # API::V1::SiteNoticesController Dismiss a notice should dismiss a notice
rspec ./spec/controllers/api/v1/site_notices_controller_spec.rb:63 # API::V1::SiteNoticesController toggle_notice_display should store collapse time and expand and collapse status
rspec ./spec/controllers/api/v1/site_notices_controller_spec.rb:99 # API::V1::SiteNoticesController Delete a Notice should delete a notice
rspec ./spec/controllers/author_notes_controller_spec.rb:27 # AuthorNotesController#show_author_note GET show_author_note
rspec ./spec/controllers/embeddable/image_questions_controller_spec.rb[1:1:2:1] # Embeddable::ImageQuestionsController it should behave like an embeddable controller GET show assigns the requested image_question as @image_question
rspec ./spec/controllers/embeddable/image_questions_controller_spec.rb[1:1:2:2] # Embeddable::ImageQuestionsController it should behave like an embeddable controller GET show assigns the requested image_question as @image_question when called with Ajax
rspec ./spec/controllers/embeddable/multiple_choices_controller_spec.rb[1:1:2:2] # Embeddable::MultipleChoicesController it should behave like an embeddable controller GET show assigns the requested multiple_choice as @multiple_choice when called with Ajax
rspec ./spec/controllers/embeddable/open_responses_controller_spec.rb[1:1:2:2] # Embeddable::OpenResponsesController it should behave like an embeddable controller GET show assigns the requested open_response as @open_response when called with Ajax
rspec ./spec/controllers/portal/clazzes_controller_spec.rb:98 # Portal::ClazzesController XMLHttpRequest edit should not allow me to modify the requested class's school
rspec ./spec/controllers/portal/clazzes_controller_spec.rb[1:2:4] # Portal::ClazzesController XMLHttpRequest edit populates the list of available teachers for ADD functionality if current user is a admin_user
rspec ./spec/controllers/portal/clazzes_controller_spec.rb[1:2:5] # Portal::ClazzesController XMLHttpRequest edit populates the list of available teachers for ADD functionality if current user is a authorized_teacher_user
rspec ./spec/controllers/portal/clazzes_controller_spec.rb[1:3:1] # Portal::ClazzesController POST add_teacher will add the selected teacher to the given class if the current user is authorized
rspec ./spec/controllers/portal/clazzes_controller_spec.rb[1:3:2] # Portal::ClazzesController POST add_teacher will add the selected teacher to the given class if the current user is authorized
rspec ./spec/controllers/portal/clazzes_controller_spec.rb[1:3:3] # Portal::ClazzesController POST add_teacher will add the selected teacher to the given class if the current user is authorized
rspec ./spec/controllers/portal/clazzes_controller_spec.rb[1:4:1] # Portal::ClazzesController DELETE remove_teacher will remove the selected teacher from the given class if the current user is authorized
rspec ./spec/controllers/portal/clazzes_controller_spec.rb[1:4:2] # Portal::ClazzesController DELETE remove_teacher will remove the selected teacher from the given class if the current user is authorized
rspec ./spec/controllers/portal/clazzes_controller_spec.rb[1:4:3] # Portal::ClazzesController DELETE remove_teacher will remove the selected teacher from the given class if the current user is authorized
rspec ./spec/controllers/portal/clazzes_controller_spec.rb:207 # Portal::ClazzesController DELETE remove_teacher will not let me remove the last teacher from the given class
rspec ./spec/controllers/portal/clazzes_controller_spec.rb:221 # Portal::ClazzesController DELETE remove_teacher will disable the remaining delete button if there is only one remaining teacher after this operation
rspec ./spec/controllers/portal/clazzes_controller_spec.rb:243 # Portal::ClazzesController DELETE remove_teacher will re-render the teacher listing when a teacher is removed
rspec ./spec/controllers/portal/clazzes_controller_spec.rb[1:4:7] # Portal::ClazzesController DELETE remove_teacher will redirect the user to their home page if they remove themselves from a class
rspec ./spec/controllers/portal/clazzes_controller_spec.rb[1:4:8] # Portal::ClazzesController DELETE remove_teacher will redirect the user to their home page if they remove themselves from a class
rspec ./spec/controllers/portal/clazzes_controller_spec.rb:499 # Portal::ClazzesController PUT update should not let me update a class with no grade levels when grade levels are enabled
rspec ./spec/controllers/portal/clazzes_controller_spec.rb:522 # Portal::ClazzesController POST add_offering should run without error
rspec ./spec/controllers/portal/clazzes_controller_spec.rb:564 # Portal::ClazzesController Post edit class information should not save the edited class info if the class name is blank
rspec ./spec/controllers/portal/clazzes_controller_spec.rb:572 # Portal::ClazzesController Post edit class information should not save the edited class info if the class word is blank
rspec ./spec/controllers/portal/clazzes_controller_spec.rb:583 # Portal::ClazzesController Post add a new student to a class should add a new student to the class
rspec ./spec/controllers/portal/clazzes_controller_spec.rb:628 # Portal::ClazzesController Put teacher Manage class should should save all the activated and deactivated classes and in the right order
rspec ./spec/controllers/portal/clazzes_controller_spec.rb:716 # Portal::ClazzesController GET edit saves the position of the left pane submenu item for an authorized teacher
rspec ./spec/controllers/portal/schools_controller_spec.rb:179 # Portal::SchoolsController DELETE destroy renders the rjs template
rspec ./spec/controllers/portal/schools_controller_spec.rb:185 # Portal::SchoolsController DELETE destroy the rjs response should remove a dom elemet
rspec ./spec/controllers/portal/students_controller_spec.rb:187 # Portal::StudentsController GET show should not redirect when current user is an admin
rspec ./spec/controllers/portal/students_controller_spec.rb:281 # Portal::StudentsController POST move_confirm should ask for confirmation
rspec ./spec/controllers/portal/students_controller_spec.rb:286 # Portal::StudentsController POST move_confirm should notify if one or both of the class words are invalid
rspec ./spec/controllers/portal/students_controller_spec.rb:291 # Portal::StudentsController POST move_confirm should notify if the student is already in the class specified to move to
rspec ./spec/controllers/portal/students_controller_spec.rb:296 # Portal::StudentsController POST move_confirm should notify if the student is not in the class specified to move from
rspec ./spec/controllers/portal/students_controller_spec.rb:376 # Portal::StudentsController#register GET register
rspec ./spec/controllers/search_controller_spec.rb:149 # SearchController POST add_material_to_clazzes should assign only unassigned investigations to the classes
rspec ./spec/controllers/search_controller_spec.rb:172 # SearchController POST add_material_to_clazzes should assign activities to the classes
rspec ./spec/controllers/search_controller_spec.rb:200 # SearchController POST add_material_to_collections should add materials to a collection
rspec ./spec/controllers/teacher_notes_controller_spec.rb:9 # TeacherNotesController#show_teacher_note GET show_teacher_note
rspec ./spec/helpers/application_helper_spec.rb:225 # ApplicationHelper#edit_button_for works
rspec ./spec/helpers/application_helper_spec.rb:513 # ApplicationHelper#remote_link_button works
rspec ./spec/views/admin/settings/show.html.haml_spec.rb:14 # /admin/settings/show.html.haml should show the pub interval
rspec ./spec/views/admin/tags/show.html.haml_spec.rb:14 # /admin/tags/show.html.haml renders attributes in <p>
rspec ./spec/views/dataservice/blobs/index.html.haml_spec.rb:23 # /dataservice/blobs/index.html.haml renders a list of dataservice_blobs
rspec ./spec/views/dataservice/blobs/show.html.haml_spec.rb:18 # /dataservice/blobs/show.html.haml renders attributes in <p>
rspec ./spec/views/embeddables/open_responses/edit.html.haml_spec.rb:20 # /embeddable/open_responses/edit.html.haml renders the edit form
rspec ./spec/views/embeddables/open_responses/edit.html.haml_spec.rb:24 # /embeddable/open_responses/edit.html.haml should have a prompt tag
rspec ./spec/views/embeddables/open_responses/edit.html.haml_spec.rb:28 # /embeddable/open_responses/edit.html.haml should have a rows field
rspec ./spec/views/embeddables/open_responses/show.html.haml_spec.rb:20 # /embeddable/open_responses/show.html.haml should have a rows field
rspec ./spec/views/embeddables/open_responses/show.html.haml_spec.rb:24 # /embeddable/open_responses/show.html.haml should have a columns field
rspec ./spec/views/images/index.html.haml_spec.rb:16 # /images/index.html.haml should render list of images without error
rspec ./spec/views/materials_collections/index.html.haml_spec.rb:15 # materials_collections/index renders a list of materials_collections
rspec ./spec/views/materials_collections/show.html.haml_spec.rb:10 # materials_collections/show renders attributes in accordion (no materials)
rspec ./spec/views/materials_collections/show.html.haml_spec.rb:19 # materials_collections/show renders attributes in accordion (with materials)

As part of this work, we should identify unused views (perhaps student registration?)


## Steps Todo:
* Rails 4 upgrade

## Steps Done:

* Upgrade Rails to 3.2.22.19
  * run `bundle update rails --patch` inside docker container to get to latest patch version
  * Test it on travis
* Upgrade Ruby version file to to 2.3.7
* Update Docker image (docker-rails-base-private)

## How to update the Base Docker image

Note: The Private Dockerhub repo named `docker-rails-base-private` Dockerfile is stored at
the Concord github repo named `docker-rails-base`

1. Check out the Concord Base image repo `git@github.com:concord-consortium/docker-rails-base.git`
2. Switch to the `ruby23` branch.
3. edit the Dockerfile
4. Build the docker image: `docker build . -t concordconsortium/docker-rails-base-private:<new-tag-here> --build-arg RAILS_LTS_PASS=<replace-with-password>`  `new-tag` is of the format `ruby-x.x.x-rails-x.x.x.xx` resulting in tag names like:
`concordconsortium/docker-rails-base-private:ruby-2.3.7-rails-3.2.22.19`
5. Push the build to dockerhub: `docker push concordconsortium/docker-rails-base-private:<new-tag-here>`






## Note about ruby versions supported

Prior to 9th April 2019, stable branches of Rails since 3.0 use travis-ci for automated testing, and the list of tested ruby versions, by rails branch, is:

### Rails 4.0

- 1.9.3
- 2.0.0
- 2.1
- 2.2

### Rails 4.1

- 1.9.3
- 2.0.0
- 2.1
- 2.2.4
- 2.3.0

### Rails 4.2

- 1.9.3
- 2.0.0-p648
- 2.1.10
- 2.2.10
- 2.3.8
- 2.4.5

### Rails 5.0

- 2.2.10
- 2.3.8
- 2.4.5

### Rails 5.1

- 2.2.10
- 2.3.7
- 2.4.4
- 2.5.1

### Rails 5.2

- 2.2.10
- 2.3.7
- 2.4.4
- 2.5.1

### Rails 6.0

- 2.5.3
- 2.6.0
