class AddMoreMissingIndexes < ActiveRecord::Migration
  def resilient_add_index(*arguments)
    begin
      add_index *arguments
    rescue => err
      puts err
      puts "failed: #{arguments.join()}"
    end
  end

  def resilient_remove_index(*arguments)
    begin
      remove_index *arguments
    rescue => err
      puts err
      puts "failed: #{arguments.join()}"
    end
  end
  def up

    # site notices indexes
    resilient_add_index :admin_site_notices, :created_by
    resilient_add_index :admin_site_notices, :updated_by
    resilient_add_index :admin_site_notice_roles, :notice_id
    resilient_add_index :admin_site_notice_roles, :role_id
    resilient_add_index :admin_site_notice_users, :notice_id
    resilient_add_index :admin_site_notice_users, :user_id
    resilient_add_index :admin_notice_user_display_statuses, :user_id

    # bookmark indexes
    resilient_add_index :portal_bookmarks, :user_id
    resilient_add_index :portal_bookmarks, [:id, :type]
    
    # Users / Roles / Groups
    resilient_add_index :users, [:id, :type]
    resilient_add_index :users, :vendor_interface_id
    resilient_add_index :authentications, :user_id
    resilient_add_index :access_grants, :user_id
    resilient_add_index :access_grants, :client_id

    resilient_add_index :passwords, :user_id

    # vendor interface / probe
    resilient_add_index :admin_project_vendor_interfaces, :admin_project_id
    resilient_add_index :admin_project_vendor_interfaces, :probe_vendor_interface_id, :name => "adm_proj_vndr_interfc"
    resilient_add_index :admin_project_vendor_interfaces, [:admin_project_id, :probe_vendor_interface_id], :name => "adm_proj_interface"
    
    resilient_add_index :portal_learners, :student_id
    resilient_add_index :report_learners, [:runnable_id, :runnable_type]

    resilient_add_index :report_embeddable_filters, :offering_id
    
    resilient_add_index :portal_schools, :district_id
    resilient_add_index :portal_schools, :nces_school_id
    resilient_add_index :portal_schools, :country_id
    resilient_add_index :portal_school_memberships, [:school_id, :member_id, :member_type], :name => 'school_memberships_long_idx'
    resilient_add_index :portal_districts, :nces_district_id

    resilient_add_index :external_activities, :user_id
    resilient_add_index :external_activities, [:template_id, :template_type]

    resilient_add_index :page_elements, [:embeddable_id, :embeddable_type]
    resilient_add_index :embeddable_data_collectors, :probe_type_id
    resilient_add_index :probe_probe_types, :user_id
    resilient_add_index :probe_device_configs, :user_id
    resilient_add_index :probe_device_configs, :vendor_interface_id

    resilient_add_index :portal_offerings, :clazz_id
  
    resilient_add_index :dataservice_bundle_loggers, :in_progress_bundle_id

    resilient_add_index :saveable_external_link_urls, :external_link_id
    resilient_add_index :saveable_external_links, :learner_id
    resilient_add_index :saveable_external_links, :offering_id
    resilient_add_index :saveable_external_links, [:embeddable_id, :embeddable_type], :name => 'svbl_xtrn_links_poly'
    
    resilient_add_index :saveable_multiple_choices, :multiple_choice_id    
    resilient_add_index :saveable_image_questions, :image_question_id
    resilient_add_index :saveable_open_responses, :open_response_id
  end

  def down
    resilient_remove_index :admin_site_notices, :created_by
    resilient_remove_index :admin_site_notices, :updated_by
    resilient_remove_index :admin_site_notice_roles, :notice_id
    resilient_remove_index :admin_site_notice_roles, :role_id
    resilient_remove_index :admin_site_notice_users, :notice_id
    resilient_remove_index :admin_site_notice_users, :user_id
    resilient_remove_index :admin_notice_user_display_statuses, :user_id

    # bookmark indexes
    resilient_remove_index :portal_bookmarks, :user_id
    resilient_remove_index :portal_bookmarks, [:id, :type]
    
    # Users / Roles / Groups
    resilient_remove_index :users, [:id, :type]
    resilient_remove_index :users, :vendor_interface_id
    resilient_remove_index :authentications, :user_id
    resilient_remove_index :access_grants, :user_id
    resilient_remove_index :access_grants, :client_id

    resilient_remove_index :passwords, :user_id


    # vendor interface / probe
    resilient_remove_index :admin_project_vendor_interfaces, :admin_project_id
    resilient_remove_index :admin_project_vendor_interfaces, :name => "adm_proj_vndr_interfc"
    resilient_remove_index :admin_project_vendor_interfaces, :name => "adm_proj_interface"
    
    resilient_remove_index :portal_learners, :student_id
    resilient_remove_index :report_learners, [:runnable_id, :runnable_type]
    
    resilient_remove_index :report_embeddable_filters, :offering_id
    
    resilient_remove_index :portal_schools, :district_id
    resilient_remove_index :portal_schools, :nces_school_id
    resilient_remove_index :portal_schools, :country_id
    resilient_remove_index :portal_school_memberships, :name => 'school_memberships_long_idx'


    resilient_remove_index :portal_districts, :nces_district_id

    resilient_remove_index :external_activities, :user_id
    resilient_remove_index :external_activities, [:template_id, :template_type]

    resilient_remove_index :page_elements, [:embeddable_id, :embeddable_type]
    resilient_remove_index :embeddable_data_collectors, :probe_type_id
    resilient_remove_index :probe_probe_types, :user_id
    resilient_remove_index :probe_device_configs, :user_id
    resilient_remove_index :probe_device_configs, :vendor_interface_id

    resilient_remove_index :portal_offerings, :clazz_id
  
    resilient_remove_index :dataservice_bundle_loggers, :in_progress_bundle_id

    resilient_remove_index :saveable_external_link_urls, :external_link_id
    resilient_remove_index :saveable_external_links, :learner_id
    resilient_remove_index :saveable_external_links, :offering_id
    resilient_remove_index :saveable_external_links, :name => 'svbl_xtrn_links_poly'
    
    resilient_remove_index :saveable_multiple_choices, :multiple_choice_id    
    resilient_remove_index :saveable_image_questions, :image_question_id
    resilient_remove_index :saveable_open_responses, :open_response_id
  end
end