class AddEmbeddableDiySection < ActiveRecord::Migration
  def self.up
    create_table :embeddable_diy_sections, :force => true  do |t|
      t.integer     :user_id
      t.string      :uuid,      :limit => 36
      t.string      :name
      t.text        :description
      t.text        :content
      t.text        :default_response
      t.boolean     :has_question
      t.timestamps 
    end
    add_index :embeddable_diy_sections, :name
    add_index :embeddable_diy_sections, :has_question
    add_index :embeddable_diy_sections, :uuid


  end

  def self.down
    remove_index :embeddable_diy_sections, :name
    remove_index :embeddable_diy_sections, :has_question
    remove_index :embeddable_diy_sections, :uuid
    drop_table :embeddable_diy_sections
  end
end
