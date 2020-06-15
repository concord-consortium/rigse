class RemoveResourcePages < ActiveRecord::Migration
  def up
    drop_table :resource_pages
    drop_table :student_views
    drop_table :attached_files
  end

  def down
    create_table "resource_pages", :force => true do |t|
      t.integer  "user_id"
      t.string   "name"
      t.text     "description"
      t.string   "publication_status",               :default => "draft"
      t.datetime "created_at",                                            :null => false
      t.datetime "updated_at",                                            :null => false
      t.integer  "offerings_count",                  :default => 0
      t.text     "content"
      t.string   "uuid",               :limit => 36
    end

    create_table "student_views", :force => true do |t|
      t.integer "user_id",       :null => false
      t.integer "viewable_id",   :null => false
      t.string  "viewable_type", :null => false
      t.integer "count"
    end

    create_table "attached_files", :force => true do |t|
      t.integer  "user_id"
      t.string   "name"
      t.string   "attachable_type"
      t.integer  "attachable_id"
      t.string   "attachment_file_name"
      t.string   "attachment_content_type"
      t.integer  "attachment_file_size"
      t.datetime "attachment_updated_at"
      t.datetime "created_at",              :null => false
      t.datetime "updated_at",              :null => false
    end
  end
end
