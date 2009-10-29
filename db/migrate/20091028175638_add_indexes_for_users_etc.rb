class AddIndexesForUsersEtc < ActiveRecord::Migration
  def self.up
    add_index     :portal_teachers,        :user_id
    add_index     :portal_students,        :user_id
    add_index     :portal_courses,         :name
    add_index     :portal_courses,         :school_id
    add_index     :portal_clazzes,         :class_word
    add_index     :portal_nces06_schools,  :SEASCH    # State's own ID for the school.
  end

  def self.down
    remove_index  :portal_teachers,        :user_id
    remove_index  :portal_students,        :user_id
    remove_index  :portal_courses,         :name
    remove_index  :portal_courses,         :school_id
    remove_index  :portal_clazzes,         :class_word
    remove_index  :portal_nces06_schools,  :SEASCH    # State's own ID for the school.
  end
end
