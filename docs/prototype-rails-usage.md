## Summary

Total number of blocks:  237

Blocks not fixed      : 173

## Story 174370119

https://www.pivotaltracker.com/story/show/174370119
|   | Fixed | Block                                                                    | Calls                                  | Num Callers |
| - | ----- | ------------------------------------------------------------------------ | -------------------------------------- | ----------- |
| 1 |       | assets/javascripts/search_materials.js#get_Assign_To_Class_Popup         |                                        |             |
| 2 |       | controllers/search_controller.rb#add_material_to_clazzes                 | render :update                         |             |
| 3 |       | controllers/search_controller.rb#get_current_material_anonymous          | _material_unassigned_clazzes.html.haml |             |
| 4 |       | controllers/search_controller.rb#get_current_material_unassigned_clazzes | _material_unassigned_clazzes.html.haml |             |
| 5 |       | views/search/_material_unassigned_clazzes.html.haml                      | link_to_remote                         | 2           |

## Story 174370395

https://www.pivotaltracker.com/story/show/174370395
|   | Fixed | Block                                                                                   | Calls                                      | Num Callers |
| - | ----- | --------------------------------------------------------------------------------------- | ------------------------------------------ | ----------- |
| 1 |       | assets/javascripts/search_materials_add_to_collection.js#get_Assign_To_Collection_Popup |                                            |             |
| 2 |       | controllers/search_controller.rb#add_material_to_collections                            | render :update                             |             |
| 3 |       | controllers/search_controller.rb#get_current_material_unassigned_collections            | _material_unassigned_collections.html.haml |             |
| 4 |       | views/search/_material_unassigned_collections.html.haml                                 | link_to_remote                             | 1           |

## Story 174373021

https://www.pivotaltracker.com/story/show/174373021
|   | Fixed | Block                                          | Calls | Num Callers |
| - | ----- | ---------------------------------------------- | ----- | ----------- |
| 1 | Y     | controllers/admin/clients_controller.rb#edit   |       |             |
| 2 | Y     | controllers/admin/clients_controller.rb#update |       |             |
| 3 | Y     | views/admin/clients/_remote_form.html.haml     |       |             |
| 4 | Y     | views/admin/clients/index.html.haml            |       |             |

## Story 174373050

https://www.pivotaltracker.com/story/show/174373050
|   | Fixed | Block                                                   | Calls | Num Callers |
| - | ----- | ------------------------------------------------------- | ----- | ----------- |
| 1 | Y     | controllers/admin/commons_licenses_controller.rb#edit   |       |             |
| 2 | Y     | controllers/admin/commons_licenses_controller.rb#update |       |             |
| 3 | Y     | views/admin/commons_licenses/_remote_form.html.haml     |       |             |
| 4 | Y     | views/admin/commons_licenses/index.html.haml            |       |             |

## Story 174373092

https://www.pivotaltracker.com/story/show/174373092
|   | Fixed | Block                                                   | Calls | Num Callers |
| - | ----- | ------------------------------------------------------- | ----- | ----------- |
| 1 | Y     | controllers/admin/external_reports_controller.rb#edit   |       |             |
| 2 | Y     | controllers/admin/external_reports_controller.rb#update |       |             |
| 3 | Y     | views/admin/external_reports/_remote_form.html.haml     |       |             |
| 4 | Y     | views/admin/external_reports/index.html.haml            |       |             |

## Story 174373123

https://www.pivotaltracker.com/story/show/174373123
|   | Fixed | Block                                           | Calls                                                                                    | Num Callers |
| - | ----- | ----------------------------------------------- | ---------------------------------------------------------------------------------------- | ----------- |
| 1 |       | controllers/admin/projects_controller.rb#edit   | _remote_form.html.haml                                                                   |             |
| 2 |       | controllers/admin/projects_controller.rb#update | _remote_form.html.haml, _show.html.haml                                                  |             |
| 3 |       | views/admin/projects/_remote_form.html.haml     | remote_form_for                                                                          | 2           |
| 4 |       | views/admin/projects/_show.html.haml            | application_helper.rb#wrap_edit_link_around_content, application_helper.rb#show_menu_for | 3           |
| 5 |       | views/admin/projects/index.html.haml            | _show.html.haml                                                                          |             |
| 6 |       | views/admin/projects/show.html.haml             | _show.html.haml                                                                          |             |

## Story 174373193

https://www.pivotaltracker.com/story/show/174373193
|   | Fixed | Block                                             | Calls                                                                                                                  | Num Callers |
| - | ----- | ------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------- | ----------- |
| 1 |       | controllers/admin/settings_controller.rb#edit     | _remote_form.html.haml                                                                                                 |             |
| 2 |       | controllers/admin/settings_controller.rb#update   | _show.html.haml                                                                                                        |             |
| 3 |       | views/admin/settings/_remote_form.html.haml       | remote_form_for                                                                                                        | 1           |
| 4 |       | views/admin/settings/_show.html.haml              | application_helper.rb#wrap_edit_link_around_content, _show_for_managers.html.haml, application_helper.rb#show_menu_for | 3           |
| 5 |       | views/admin/settings/_show_for_managers.html.haml | application_helper.rb#wrap_edit_link_around_content, application_helper.rb#show_menu_for                               | 1           |
| 6 |       | views/admin/settings/index.html.haml              | _show.html.haml                                                                                                        |             |
| 7 |       | views/admin/settings/show.html.haml               | _show.html.haml                                                                                                        |             |

## Story 174373215

https://www.pivotaltracker.com/story/show/174373215
|   | Fixed | Block                                       | Calls | Num Callers |
| - | ----- | ------------------------------------------- | ----- | ----------- |
| 1 | Y     | controllers/admin/tags_controller.rb#edit   |       |             |
| 2 | Y     | controllers/admin/tags_controller.rb#update |       |             |
| 3 | Y     | views/admin/tags/_remote_form.html.haml     |       |             |
| 4 | Y     | views/admin/tags/_show.html.haml            |       |             |
| 5 | Y     | views/admin/tags/index.html.haml            |       |             |
| 6 | Y     | views/admin/tags/show.html.haml             |       |             |

## Story 174367430

https://www.pivotaltracker.com/story/show/174367430
|   | Fixed | Block                                                               | Calls          | Num Callers |
| - | ----- | ------------------------------------------------------------------- | -------------- | ----------- |
| 1 |       | controllers/api/v1/site_notices_controller.rb#dismiss_notice        | render :update |             |
| 2 |       | controllers/api/v1/site_notices_controller.rb#remove_notice         | render :update |             |
| 3 |       | controllers/api/v1/site_notices_controller.rb#toggle_notice_display | render :update |             |

## Story 174367289

https://www.pivotaltracker.com/story/show/174367289
|   | Fixed | Block                                                   | Calls                                                                                                 | Num Callers |
| - | ----- | ------------------------------------------------------- | ----------------------------------------------------------------------------------------------------- | ----------- |
| 1 |       | controllers/author_notes_controller.rb#edit             | visual_effect, render :update                                                                         |             |
| 2 |       | controllers/author_notes_controller.rb#show_author_note | visual_effect, visual_effect, render :update, render :update, _remote_form.html.haml, _show.html.haml |             |
| 3 |       | views/author_notes/_remote_form.html.haml               | remote_form_for, visual_effect                                                                        | 1           |
| 4 |       | views/author_notes/_show.html.haml                      | link_to_function                                                                                      | 1           |

## Story 174347881

https://www.pivotaltracker.com/story/show/174347881
|    | Fixed | Block                                                            | Calls                                                                    | Num Callers |
| -- | ----- | ---------------------------------------------------------------- | ------------------------------------------------------------------------ | ----------- |
| 1  |       | controllers/embeddable/image_questions_controller.rb#edit        | _remote_form.html.haml                                                   |             |
| 2  |       | controllers/embeddable/image_questions_controller.rb#new         | _remote_form.html.haml                                                   |             |
| 3  |       | controllers/embeddable/image_questions_controller.rb#show        | _show.html.haml                                                          |             |
| 4  |       | controllers/embeddable/image_questions_controller.rb#update      | _show.html.haml                                                          |             |
| 5  |       | controllers/embeddable/multiple_choices_controller.rb#add_choice | _new_choice.html.haml                                                    |             |
| 6  |       | controllers/embeddable/multiple_choices_controller.rb#edit       | _remote_form.html.haml                                                   |             |
| 7  |       | controllers/embeddable/multiple_choices_controller.rb#new        | _remote_form.html.haml                                                   |             |
| 8  |       | controllers/embeddable/multiple_choices_controller.rb#show       | _show.html.haml                                                          |             |
| 9  |       | controllers/embeddable/multiple_choices_controller.rb#update     | _show.html.haml                                                          |             |
| 10 |       | controllers/embeddable/open_responses_controller.rb#edit         | _remote_form.html.haml                                                   |             |
| 11 |       | controllers/embeddable/open_responses_controller.rb#new          | _remote_form.html.haml                                                   |             |
| 12 |       | controllers/embeddable/open_responses_controller.rb#show         | _show.html.haml                                                          |             |
| 13 |       | controllers/embeddable/open_responses_controller.rb#update       | _show.html.haml                                                          |             |
| 14 |       | helpers/js_helper.rb#remove_link                                 | link_to_function                                                         | 1           |
| 15 |       | views/embeddable/image_questions/_remote_form.html.haml          | remote_form_for                                                          | 2           |
| 16 |       | views/embeddable/image_questions/_show.html.haml                 | application_helper.rb#wrap_edit_link_around_content                      | 3           |
| 17 |       | views/embeddable/image_questions/destroy.js.rjs                  | js_helper.rb#safe_js                                                     |             |
| 18 |       | views/embeddable/image_questions/index.html.haml                 | _embeddable_container.html.haml                                          |             |
| 19 |       | views/embeddable/image_questions/show.html.haml                  | _show.html.haml                                                          |             |
| 20 |       | views/embeddable/multiple_choices/_edit_choice.html.haml         | js_helper.rb#remove_link                                                 | 2           |
| 21 |       | views/embeddable/multiple_choices/_new_choice.html.haml          | _edit_choice.html.haml                                                   | 1           |
| 22 |       | views/embeddable/multiple_choices/_remote_form.html.haml         | remote_form_for, link_to_remote, _edit_choice.html.haml                  | 4           |
| 23 |       | views/embeddable/multiple_choices/_show.html.haml                | application_helper.rb#wrap_edit_link_around_content                      | 2           |
| 24 |       | views/embeddable/multiple_choices/add_choice.js.rjs              |                                                                          |             |
| 25 |       | views/embeddable/multiple_choices/destroy.js.rjs                 | js_helper.rb#safe_js                                                     |             |
| 26 |       | views/embeddable/multiple_choices/edit.html.haml                 | _remote_form.html.haml                                                   |             |
| 27 |       | views/embeddable/multiple_choices/index.html.haml                | _embeddable_container.html.haml                                          |             |
| 28 |       | views/embeddable/multiple_choices/new.html.haml                  | _remote_form.html.haml                                                   |             |
| 29 |       | views/embeddable/multiple_choices/show.html.haml                 | _embeddable_container.html.haml                                          |             |
| 30 |       | views/embeddable/open_responses/_remote_form.html.haml           | remote_form_for                                                          | 3           |
| 31 |       | views/embeddable/open_responses/_show.html.haml                  | application_helper.rb#wrap_edit_link_around_content                      | 2           |
| 32 |       | views/embeddable/open_responses/destroy.js.rjs                   | js_helper.rb#safe_js                                                     |             |
| 33 |       | views/embeddable/open_responses/edit.html.haml                   | _remote_form.html.haml                                                   |             |
| 34 |       | views/embeddable/open_responses/index.html.haml                  | _embeddable_container.html.haml                                          |             |
| 35 |       | views/embeddable/open_responses/show.html.haml                   | _embeddable_container.html.haml                                          |             |
| 36 |       | views/shared/_embeddable_container.html.haml                     | application_helper.rb#show_menu_for, application_helper.rb#show_menu_for | 5           |

## Story 174374781

https://www.pivotaltracker.com/story/show/174374781
|   | Fixed | Block                                                    | Calls                 | Num Callers |
| - | ----- | -------------------------------------------------------- | --------------------- | ----------- |
| 1 |       | controllers/external_activities_controller.rb#edit_basic | _basic_form.html.haml |             |
| 2 |       | views/external_activities/_basic_form.html.haml          | remote_form_for       | 1           |

## Story 174374664

https://www.pivotaltracker.com/story/show/174374664
|   | Fixed | Block                                                | Calls                                                                             | Num Callers |
| - | ----- | ---------------------------------------------------- | --------------------------------------------------------------------------------- | ----------- |
| 1 |       | controllers/external_activities_controller.rb#index  | _runnable_list.html.haml                                                          |             |
| 2 |       | controllers/external_activities_controller.rb#update | _external_activity_header.html.haml                                               |             |
| 3 |       | views/external_activities/_remote_form.html.haml     | remote_form_for                                                                   |             |
| 4 |       | views/external_activities/_runnable_list.html.haml   | draggable_element                                                                 | 2           |
| 5 |       | views/external_activities/_show.html.haml            | sortable_element                                                                  |             |
| 6 |       | views/external_activities/create.js.rjs              | visual_effect, visual_effect, page <<, js_helper.rb#safe_js, js_helper.rb#safe_js |             |
| 7 |       | views/external_activities/destroy.js.rjs             |                                                                                   |             |
| 8 |       | views/external_activities/index.html.haml            | observe_form, _runnable_list.html.haml                                            |             |
| 9 |       | views/shared/_external_activity_header.html.haml     | clipboard.rb#paste_link_for, application_helper.rb#delete_button_for              | 1           |

## Story 174373929

https://www.pivotaltracker.com/story/show/174373929
|   | Fixed | Block                                   | Calls | Num Callers |
| - | ----- | --------------------------------------- | ----- | ----------- |
| 1 | Y     | controllers/images_controller.rb#create |       |             |
| 2 | Y     | views/images/destroy.rjs                |       |             |
| 3 | Y     | views/images/index.html.haml            |       |             |

## Story 174373337

https://www.pivotaltracker.com/story/show/174373337
|   | Fixed | Block                                                          | Calls                                                                                                                        | Num Callers |
| - | ----- | -------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------- | ----------- |
| 1 |       | controllers/materials_collections_controller.rb#destroy        | render :update                                                                                                               |             |
| 2 |       | controllers/materials_collections_controller.rb#edit           | _remote_form.html.haml                                                                                                       |             |
| 3 |       | controllers/materials_collections_controller.rb#update         | _show.html.haml                                                                                                              |             |
| 4 |       | views/materials_collections/_list_show.html.haml               | _show.html.haml                                                                                                              | 2           |
| 5 |       | views/materials_collections/_materials_in_collection.html.haml | sortable_element, application_helper.rb#remote_link_button                                                                   | 1           |
| 6 |       | views/materials_collections/_remote_form.html.haml             | remote_form_for                                                                                                              | 1           |
| 7 |       | views/materials_collections/_show.html.haml                    | _materials_in_collection.html.haml, application_helper.rb#wrap_edit_link_around_content, application_helper.rb#show_menu_for | 2           |
| 8 |       | views/materials_collections/index.html.haml                    | _list_show.html.haml                                                                                                         |             |
| 9 |       | views/materials_collections/show.html.haml                     | _list_show.html.haml                                                                                                         |             |

## Story 174374264

https://www.pivotaltracker.com/story/show/174374264
|   | Fixed | Block                                                          | Calls | Num Callers |
| - | ----- | -------------------------------------------------------------- | ----- | ----------- |
| 1 | Y     | controllers/portal/bookmarks_controller.rb#add                 |       |             |
| 2 | Y     | controllers/portal/bookmarks_controller.rb#add_padlet          |       |             |
| 3 | Y     | controllers/portal/bookmarks_controller.rb#delete              |       |             |
| 4 | Y     | helpers/portal/bookmarks_helper.rb#render_add_bookmark_buttons |       |             |
| 5 | Y     | views/portal/bookmarks/_show.html.haml                         |       |             |
| 6 | Y     | views/portal/bookmarks/generic_bookmark/_button.html.haml      |       |             |
| 7 | Y     | views/portal/bookmarks/index.html.haml                         |       |             |
| 8 | Y     | views/portal/bookmarks/padlet_bookmark/_button.html.haml       |       |             |

## Story 174324301

https://www.pivotaltracker.com/story/show/174324301
|    | Fixed | Block                                                           | Calls                                                                                                                                                                                                                                                               | Num Callers |
| -- | ----- | --------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------- |
| 1  |       | controllers/portal/clazzes_controller.rb#add_new_student_popup  | _add_edit_list_for_clazz.html.haml                                                                                                                                                                                                                                  |             |
| 2  |       | controllers/portal/clazzes_controller.rb#add_student            | render :update, render :update, _table_for_clazz.html.haml, student_clazzes_helper.rb#student_add_dropdown, _current_student_list_for_clazz.html.haml                                                                                                               |             |
| 3  |       | controllers/portal/clazzes_controller.rb#roster                 | _remote_form_student_roster.html.haml                                                                                                                                                                                                                               |             |
| 4  |       | controllers/portal/students_controller.rb#create                | render :update, _table_for_clazz.html.haml, student_clazzes_helper.rb#student_add_dropdown                                                                                                                                                                          |             |
| 5  |       | helpers/portal/student_clazzes_helper.rb#student_add_dropdown   | button_to_remote                                                                                                                                                                                                                                                    | 7           |
| 6  |       | views/portal/clazzes/_form_student_roster.html.haml             | _table_for_clazz.html.haml, student_clazzes_helper.rb#student_add_dropdown                                                                                                                                                                                          | 2           |
| 7  |       | views/portal/clazzes/_remote_form_student_roster.html.haml      | remote_form_for, _form_student_roster.html.haml                                                                                                                                                                                                                     | 1           |
| 8  |       | views/portal/clazzes/roster.html.haml                           | _form_student_roster.html.haml                                                                                                                                                                                                                                      |             |
| 9  |       | views/portal/student_clazzes/destroy.js.rjs                     | page <<, page <<, page <<, page <<, page <<, page <<, page <<, page <<, _table_for_clazz.html.haml, js_helper.rb#safe_js, student_clazzes_helper.rb#student_add_dropdown, student_clazzes_helper.rb#student_add_dropdown, _current_student_list_for_clazz.html.haml |             |
| 10 |       | views/portal/students/_add_edit_list_for_clazz.html.haml        | student_clazzes_helper.rb#student_add_dropdown, _current_student_list_for_clazz.html.haml                                                                                                                                                                           | 1           |
| 11 |       | views/portal/students/_current_student_list_for_clazz.html.haml | application_helper.rb#remote_link_button                                                                                                                                                                                                                            | 3           |
| 12 |       | views/portal/students/_table_for_clazz.html.haml                | link_to_remote                                                                                                                                                                                                                                                      | 6           |

## Story 174366664

https://www.pivotaltracker.com/story/show/174366664
|    | Fixed | Block                                                    | Calls                                                                                                                                                     | Num Callers |
| -- | ----- | -------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------- |
| 1  |       | controllers/portal/clazzes_controller.rb#add_offering    | render :update, render :update, _offering_for_teacher.html.haml                                                                                           |             |
| 2  |       | controllers/portal/clazzes_controller.rb#class_list      |                                                                                                                                                           |             |
| 3  |       | controllers/portal/clazzes_controller.rb#remove_offering | render :update, render :update, _runnable.html.haml                                                                                                       |             |
| 4  |       | controllers/portal/offerings_controller.rb#show          |                                                                                                                                                           |             |
| 5  |       | views/portal/clazzes/class_list.html.haml                | _table_for_clazz.html.haml                                                                                                                                |             |
| 6  |       | views/portal/clazzes/destroy.js.rjs                      | js_helper.rb#safe_js, js_helper.rb#safe_js                                                                                                                |             |
| 7  |       | views/portal/clazzes/edit_offerings.html.haml            | drop_receiving_element, drop_receiving_element, _offering_for_teacher.html.haml, _runnable_list.html.haml                                                 |             |
| 8  |       | views/portal/clazzes/show.html.haml                      | _offering_for_teacher.html.haml                                                                                                                           |             |
| 9  |       | views/portal/offerings/_list_for_clazz.html.haml         | drop_receiving_element, drop_receiving_element, drop_receiving_element, drop_receiving_element, _offering_for_teacher.html.haml, _runnable_list.html.haml |             |
| 10 |       | views/portal/offerings/_show.html.haml                   | _offering_for_teacher.html.haml                                                                                                                           | 1           |
| 11 |       | views/portal/offerings/show.html.haml                    | _show.html.haml                                                                                                                                           |             |
| 12 |       | views/portal/students/_list_for_clazz.html.haml          | _table_for_clazz.html.haml, student_clazzes_helper.rb#student_add_dropdown                                                                                |             |
| 13 |       | views/shared/_offering_for_teacher.html.haml             | sortable_element                                                                                                                                          | 6           |
| 14 |       | views/shared/_runnable.html.haml                         | draggable_element                                                                                                                                         | 1           |
| 15 |       | views/shared/_runnable_list.html.haml                    | _runnables_listing.html.haml                                                                                                                              | 2           |
| 16 |       | views/shared/_runnables_listing.html.haml                | draggable_element                                                                                                                                         | 1           |

## Story 174318198

https://www.pivotaltracker.com/story/show/174318198
|    | Fixed | Block                                                   | Calls | Num Callers |
| -- | ----- | ------------------------------------------------------- | ----- | ----------- |
| 1  | Y     | controllers/portal/clazzes_controller.rb#add_teacher    |       |             |
| 2  | Y     | controllers/portal/clazzes_controller.rb#edit           |       |             |
| 3  | Y     | controllers/portal/clazzes_controller.rb#remove_teacher |       |             |
| 4  | Y     | helpers/portal/teachers_helper.rb#teacher_add_dropdown  |       |             |
| 5  | Y     | views/portal/clazzes/_form.html.haml                    |       |             |
| 6  | Y     | views/portal/clazzes/_remote_form.html.haml             |       |             |
| 7  | Y     | views/portal/clazzes/edit.html.haml                     |       |             |
| 8  | Y     | views/portal/clazzes/new.html.haml                      |       |             |
| 9  | Y     | views/portal/teachers/_list_for_clazz.html.haml         |       |             |
| 10 | Y     | views/portal/teachers/_list_for_clazz_setup.html.haml   |       |             |
| 11 | Y     | views/portal/teachers/_table_for_clazz.html.haml        |       |             |
| 12 | Y     | views/portal/teachers/_table_for_clazz_setup.html.haml  |       |             |

## Story 174325159

https://www.pivotaltracker.com/story/show/174325159
|   | Fixed | Block                                                   | Calls          | Num Callers |
| - | ----- | ------------------------------------------------------- | -------------- | ----------- |
| 1 |       | controllers/portal/clazzes_controller.rb#manage_classes | render(:update |             |

## Story 174373420

https://www.pivotaltracker.com/story/show/174373420
|   | Fixed | Block                                             | Calls | Num Callers |
| - | ----- | ------------------------------------------------- | ----- | ----------- |
| 1 | Y     | controllers/portal/districts_controller.rb#edit   |       |             |
| 2 | Y     | controllers/portal/districts_controller.rb#update |       |             |
| 3 | Y     | views/portal/districts/_remote_form.html.haml     |       |             |
| 4 | Y     | views/portal/districts/_show.html.haml            |       |             |
| 5 | Y     | views/portal/districts/destroy.js.rjs             |       |             |
| 6 | Y     | views/portal/districts/index.html.haml            |       |             |
| 7 | Y     | views/portal/districts/show.html.haml             |       |             |

## Story 174361480

https://www.pivotaltracker.com/story/show/174361480
|   | Fixed | Block                                           | Calls | Num Callers |
| - | ----- | ----------------------------------------------- | ----- | ----------- |
| 1 | Y     | controllers/portal/schools_controller.rb#create |       |             |
| 2 | Y     | controllers/portal/schools_controller.rb#edit   |       |             |
| 3 | Y     | controllers/portal/schools_controller.rb#show   |       |             |
| 4 | Y     | controllers/portal/schools_controller.rb#update |       |             |
| 5 | Y     | views/portal/schools/_remote_form.html.haml     |       |             |
| 6 | Y     | views/portal/schools/_show.html.haml            |       |             |
| 7 | Y     | views/portal/schools/destroy.js.rjs             |       |             |
| 8 | Y     | views/portal/schools/index.html.haml            |       |             |
| 9 | Y     | views/portal/schools/show.html.haml             |       |             |

## Story 174371038

https://www.pivotaltracker.com/story/show/174371038
|   | Fixed | Block                                             | Calls                                                        | Num Callers |
| - | ----- | ------------------------------------------------- | ------------------------------------------------------------ | ----------- |
| 1 |       | controllers/portal/students_controller.rb#confirm | visual_effect, visual_effect, render :update, render :update |             |
| 2 |       | views/home/my_classes.html.haml                   | _show.html.haml                                              |             |
| 3 |       | views/portal/students/_confirmation.html.haml     |                                                              |             |
| 4 |       | views/portal/students/_register.html.haml         | remote_form_for                                              | 2           |
| 5 |       | views/portal/students/_show.html.haml             | _move.html.haml, _register.html.haml                         | 2           |
| 6 |       | views/portal/students/register.html.haml          | _register.html.haml                                          |             |
| 7 |       | views/portal/students/show.html.haml              | _show.html.haml                                              |             |

## Story 174381113

https://www.pivotaltracker.com/story/show/174381113
|   | Fixed | Block                                                  | Calls                                | Num Callers |
| - | ----- | ------------------------------------------------------ | ------------------------------------ | ----------- |
| 1 |       | controllers/portal/students_controller.rb#move_confirm | visual_effect, render :update        |             |
| 2 |       | views/home/my_classes.html.haml                        | _show.html.haml                      |             |
| 3 |       | views/portal/students/_move.html.haml                  | remote_form_for                      | 1           |
| 4 |       | views/portal/students/_show.html.haml                  | _move.html.haml, _register.html.haml | 2           |
| 5 |       | views/portal/students/show.html.haml                   | _show.html.haml                      |             |

## Story 174381940

https://www.pivotaltracker.com/story/show/174381940
|   | Fixed | Block                                                   | Calls          | Num Callers |
| - | ----- | ------------------------------------------------------- | -------------- | ----------- |
| 1 |       | controllers/search_controller.rb#get_search_suggestions | render :update |             |

## Story 174365885

https://www.pivotaltracker.com/story/show/174365885
|   | Fixed | Block                                                     | Calls                                                                                                 | Num Callers |
| - | ----- | --------------------------------------------------------- | ----------------------------------------------------------------------------------------------------- | ----------- |
| 1 |       | controllers/teacher_notes_controller.rb#show_teacher_note | visual_effect, visual_effect, render :update, render :update, _remote_form.html.haml, _show.html.haml |             |
| 2 |       | views/teacher_notes/_remote_form.html.haml                | remote_form_for, visual_effect                                                                        | 1           |
| 3 |       | views/teacher_notes/_show.html.haml                       | link_to_function                                                                                      | 1           |

## Story 174365484

https://www.pivotaltracker.com/story/show/174365484
|   | Fixed | Block                                                       | Calls                                                                          | Num Callers |
| - | ----- | ----------------------------------------------------------- | ------------------------------------------------------------------------------ | ----------- |
| 1 |       | helpers/application_helper.rb#delete_button_for             | application_helper.rb#remote_link_button                                       | 8           |
| 2 |       | helpers/application_helper.rb#remote_link_button            | link_to_remote                                                                 | 9           |
| 3 |       | helpers/application_helper.rb#show_menu_for                 | application_helper.rb#edit_button_for, application_helper.rb#delete_button_for | 11          |
| 4 |       | helpers/application_helper.rb#toggle_all                    | link_to_function                                                               | 3           |
| 5 |       | helpers/application_helper.rb#wrap_edit_link_around_content | remote_function                                                                | 10          |
| 6 |       | helpers/js_helper.rb#safe_js                                | page <<, page <<                                                               | 8           |
| 7 |       | lib/clipboard.rb#paste_link_for                             | link_to_remote, application_helper.rb#remote_link_button                       | 5           |
| 8 | Y     | views/shared/_collection_menu.html.haml                     |                                                                                |             |

## Story remove after rest of work is done

remove after rest of work is done
|   | Fixed | Block                                         | Calls                                    | Num Callers |
| - | ----- | --------------------------------------------- | ---------------------------------------- | ----------- |
| 1 |       | helpers/application_helper.rb#edit_button_for | application_helper.rb#remote_link_button | 1           |

## Story 174353979

https://www.pivotaltracker.com/story/show/174353979
|   | Fixed | Block                                              | Calls                                                                                                                                                                                  | Num Callers |
| - | ----- | -------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------- |
| 1 |       | helpers/application_helper.rb#function_link_button | link_to_function                                                                                                                                                                       |             |
| 2 |       | helpers/application_helper.rb#toggle_more          | visual_effect, link_to_function                                                                                                                                                        |             |
| 3 |       | views/shared/_activity_header.haml                 | application_helper.rb#toggle_all, clipboard.rb#paste_link_for, _notes_menu.html.haml, application_helper.rb#delete_button_for, application_helper.rb#delete_button_for                 |             |
| 4 |       | views/shared/_activity_trail.html.haml             | link_to_function                                                                                                                                                                       |             |
| 5 |       | views/shared/_classes_for_school.haml              | _offering_for_teacher.html.haml                                                                                                                                                        |             |
| 6 |       | views/shared/_notes_menu.html.haml                 | application_helper.rb#remote_link_button, application_helper.rb#remote_link_button, application_helper.rb#remote_link_button, application_helper.rb#remote_link_button                 | 3           |
| 7 |       | views/shared/_page_header.html.haml                | link_to_remote, application_helper.rb#toggle_all, clipboard.rb#paste_link_for, _notes_menu.html.haml, application_helper.rb#delete_button_for, application_helper.rb#delete_button_for |             |
| 8 |       | views/shared/_paste_link.html.haml                 | clipboard.rb#paste_link_for                                                                                                                                                            |             |
| 9 |       | views/shared/_section_header.html.haml             | application_helper.rb#toggle_all, clipboard.rb#paste_link_for, _notes_menu.html.haml, application_helper.rb#delete_button_for, application_helper.rb#delete_button_for                 |             |

## Story 174354182

https://www.pivotaltracker.com/story/show/174354182
|    | Fixed | Block                                                     | Calls                                                                                    | Num Callers |
| -- | ----- | --------------------------------------------------------- | ---------------------------------------------------------------------------------------- | ----------- |
| 1  |       | views/dataservice/blobs/_remote_form.html.haml            | remote_form_for                                                                          |             |
| 2  |       | views/dataservice/blobs/_show.html.haml                   | application_helper.rb#wrap_edit_link_around_content, application_helper.rb#show_menu_for | 2           |
| 3  |       | views/dataservice/blobs/index.html.haml                   | _show.html.haml                                                                          |             |
| 4  |       | views/dataservice/blobs/show.html.haml                    | _show.html.haml                                                                          |             |
| 5  |       | views/dataservice/bundle_contents/_remote_form.html.haml  | remote_form_for                                                                          |             |
| 6  | Y     | views/dataservice/bundle_contents/index.html.haml         |                                                                                          |             |
| 7  |       | views/dataservice/bundle_loggers/_remote_form.html.haml   | remote_form_for                                                                          |             |
| 8  |       | views/dataservice/bundle_loggers/_show.html.haml          | application_helper.rb#show_menu_for                                                      | 3           |
| 9  |       | views/dataservice/bundle_loggers/index.html.haml          | _show.html.haml                                                                          |             |
| 10 |       | views/dataservice/bundle_loggers/show.html.haml           | _show.html.haml                                                                          |             |
| 11 |       | views/dataservice/console_contents/_remote_form.html.haml | remote_form_for                                                                          |             |
| 12 | Y     | views/dataservice/console_contents/index.html.haml        |                                                                                          |             |
| 13 |       | views/dataservice/console_loggers/_remote_form.html.haml  | remote_form_for                                                                          |             |
| 14 |       | views/dataservice/console_loggers/_show.html.haml         | application_helper.rb#show_menu_for                                                      | 3           |
| 15 |       | views/dataservice/console_loggers/index.html.haml         | _show.html.haml                                                                          |             |
| 16 |       | views/dataservice/console_loggers/show.html.haml          | _show.html.haml                                                                          |             |
| 17 |       | views/portal/learners/bundle_report.html.haml             | _show.html.haml, _show.html.haml                                                         |             |

## Story 174374528

https://www.pivotaltracker.com/story/show/174374528
|   | Fixed | Block                                   | Calls | Num Callers |
| - | ----- | --------------------------------------- | ----- | ----------- |
| 1 | Y     | views/installer_reports/index.html.haml |       |             |

## Story 174374504

https://www.pivotaltracker.com/story/show/174374504
|   | Fixed | Block                              | Calls | Num Callers |
| - | ----- | ---------------------------------- | ----- | ----------- |
| 1 | Y     | views/interactives/index.html.haml |       |             |
| 2 | Y     | views/users/index.html.haml        |       |             |

## Story 174366238

https://www.pivotaltracker.com/story/show/174366238
|   | Fixed | Block                                         | Calls                                                                                        | Num Callers |
| - | ----- | --------------------------------------------- | -------------------------------------------------------------------------------------------- | ----------- |
| 1 |       | views/layouts/application.html.haml           | _accordion_nav.html.haml, _general_accordion_nav.html.haml, _general_accordion_nav.html.haml |             |
| 2 |       | views/shared/_accordion_nav.html.haml         | sortable_element, sortable_element                                                           | 1           |
| 3 |       | views/shared/_general_accordion_nav.html.haml | sortable_element, sortable_element                                                           | 2           |

## Story 174373749

https://www.pivotaltracker.com/story/show/174373749
|   | Fixed | Block                                            | Calls                                                                                    | Num Callers |
| - | ----- | ------------------------------------------------ | ---------------------------------------------------------------------------------------- | ----------- |
| 1 |       | views/portal/grade_levels/_remote_form.html.haml | remote_form_for                                                                          |             |
| 2 |       | views/portal/grade_levels/_show.html.haml        | application_helper.rb#wrap_edit_link_around_content, application_helper.rb#show_menu_for | 2           |
| 3 |       | views/portal/grade_levels/index.html.haml        | _show.html.haml                                                                          |             |
| 4 |       | views/portal/grade_levels/show.html.haml         | _show.html.haml                                                                          |             |
| 5 |       | views/portal/grades/_remote_form.html.haml       | remote_form_for                                                                          |             |
| 6 |       | views/portal/grades/_show.html.haml              | application_helper.rb#wrap_edit_link_around_content, application_helper.rb#show_menu_for | 2           |
| 7 |       | views/portal/grades/index.html.haml              | _show.html.haml                                                                          |             |
| 8 |       | views/portal/grades/show.html.haml               | _show.html.haml                                                                          |             |

## Story 174374611

https://www.pivotaltracker.com/story/show/174374611
|   | Fixed | Block                                        | Calls           | Num Callers |
| - | ----- | -------------------------------------------- | --------------- | ----------- |
| 1 |       | views/portal/learners/_remote_form.html.haml | remote_form_for |             |
| 2 | Y     | views/portal/learners/index.html.haml        |                 |             |

## Story 174388646

https://www.pivotaltracker.com/story/show/174388646
|   | Fixed | Block                                   | Calls | Num Callers |
| - | ----- | --------------------------------------- | ----- | ----------- |
| 1 |       | views/portal/school_selector/update.rjs |       |             |
| 2 |       | views/shared/_school_selector.html.haml |       |             |


-------
This was generated using: cd rails/script; ruby prototype-rails-usage.rb