class CreateSaveableDrawingTools < ActiveRecord::Migration
  def self.up
    create_table "saveable_drawing_tool_answers", :force => true do |t|
      t.integer  "drawing_tool_id"
      t.integer  "bundle_content_id"
      t.integer  "position"
      t.text     "answer"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "saveable_drawing_tool_answers", ["drawing_tool_id", "position"], :name => "d_t_id_and_position_index"

    create_table "saveable_drawing_tools", :force => true do |t|
      t.integer  "learner_id"
      t.integer  "drawing_tool_id"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "offering_id"
      t.integer  "response_count",   :default => 0
    end

    add_index "saveable_drawing_tools", ["learner_id"], :name => "index_saveable_drawing_tools_on_learner_id"
    add_index "saveable_drawing_tools", ["offering_id"], :name => "index_saveable_drawing_tools_on_offering_id"
  end

  def self.down
    drop_table "saveable_drawing_tool_answers"
    drop_table "saveable_drawing_tools"
  end
end
