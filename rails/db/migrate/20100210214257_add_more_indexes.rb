class AddMoreIndexes < ActiveRecord::Migration
  def self.up
    add_index :embeddable_multiple_choice_choices, :multiple_choice_id
    add_index :saveable_open_response_answers, [:open_response_id, :position], :name => 'o_r_id_and_position_index'
    add_index :saveable_multiple_choice_answers, [:multiple_choice_id, :position], :name => 'm_c_id_and_position_index'
    add_index :pages, [:section_id, :position]
    add_index :sections, [:activity_id, :position]
    add_index :activities, [:investigation_id, :position]
    add_index :portal_student_clazzes, [:student_id, :clazz_id], :name => 'student_class_index'
    add_index :portal_student_clazzes, :clazz_id
    add_index :portal_school_memberships, [:member_type, :member_id], :name => 'member_type_id_index'
    add_index :roles_users, [:role_id, :user_id]
    add_index :roles_users, [:user_id, :role_id]
    
  end

  def self.down
    remove_index :roles_users, [:user_id, :role_id]
    remove_index :roles_users, [:role_id, :user_id]
    remove_index :portal_school_memberships, :name => 'member_type_id_index'
    remove_index :portal_student_clazzes, :clazz_id
    remove_index :portal_student_clazzes, :name => 'student_class_index'
    remove_index :activities, [:investigation_id, :position]
    remove_index :sections, [:activity_id, :position]
    remove_index :pages, [:section_id, :position]
    remove_index :saveable_multiple_choice_answers, :name => 'm_c_id_and_position_index'
    remove_index :saveable_open_response_answers, :name => 'o_r_id_and_position_index'
    remove_index :embeddable_multiple_choice_choices, :multiple_choice_id
  end
end
