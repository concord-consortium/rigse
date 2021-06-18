class RemoveBundleModelsAndColumns < ActiveRecord::Migration[6.1]
  def up
    remove_column :dataservice_blobs, :bundle_content_id
    remove_column :dataservice_blobs, :periodic_bundle_content_id

    remove_column :portal_learners, :bundle_logger_id
    remove_column :portal_learners, :console_logger_id

    remove_column :admin_settings, :use_periodic_bundle_uploading

    remove_column :saveable_external_link_urls, :bundle_content_id
    remove_column :saveable_image_question_answers, :bundle_content_id
    remove_column :saveable_multiple_choice_answers, :bundle_content_id
    remove_column :saveable_interactive_states, :bundle_content_id
    remove_column :saveable_open_response_answers, :bundle_content_id

    drop_table :dataservice_bucket_contents
    drop_table :dataservice_bucket_log_items
    drop_table :dataservice_bucket_loggers
    drop_table :dataservice_bundle_contents
    drop_table :dataservice_bundle_loggers
    drop_table :dataservice_console_contents
    drop_table :dataservice_console_loggers
    drop_table :dataservice_launch_process_events
    drop_table :dataservice_periodic_bundle_contents
    drop_table :dataservice_periodic_bundle_loggers
    drop_table :dataservice_periodic_bundle_parts
    drop_table :legacy_collaborations
  end

  def down
    # no going back!
    raise ActiveRecord::IrreversibleMigration
  end
end
