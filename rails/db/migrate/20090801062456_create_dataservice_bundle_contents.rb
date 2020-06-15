class CreateDataserviceBundleContents < ActiveRecord::Migration
  def self.up
    create_table :dataservice_bundle_contents do |t|
      t.integer :bundle_logger_id
      t.integer :position
      
      t.text :body

      # t.local_ip  :string
      # t.session_uuid :string
      # t.start :datetime
      # t.stop  :datetime
      # t.time_difference :INTEGER
      # 
      # t.datetime :sail_session_start_time
      # t.datetime :sail_session_end_time
      # t.string   :sail_curnit_uuid
      # t.string   :sail_session_uuid
      # t.boolean  :content_well_formed_xml
      # t.integer  :bundle_content_id
      # t.text     :processing_error
      # t.boolean  :has_data
      # t.datetime :sail_session_modified_time
      # t.datetime :updated_at
      # t.boolean  :is_otml
      # t.string   :maven_jnlp_version
      # t.string   :sds_time
      # t.string   :sailotrunk_otmlurl
      # t.string   :jnlp_properties
      # t.string   :previous_bundle_session_id
      # t.integer  :original_bundle_content_id
      
      t.timestamps
    end
  end

  def self.down
    drop_table :dataservice_bundle_contents
  end
end
