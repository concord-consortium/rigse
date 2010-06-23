class AddSecurityQuestions < ActiveRecord::Migration
  def self.up
    create_table :security_questions do |t|
      t.integer   :user_id, :null => false
      
      t.string    :question, :null => false, :limit => 100
      t.string    :answer, :null => false, :limit => 100
    end
    add_index     :security_questions, :user_id
  end

  def self.down
    drop_table    :security_questions
    remove_index  :security_questions, :user_id
  end
end
