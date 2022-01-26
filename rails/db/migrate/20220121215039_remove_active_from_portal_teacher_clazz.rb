class RemoveActiveFromPortalTeacherClazz < ActiveRecord::Migration[6.1]
  def change
    remove_column :portal_teacher_clazzes, :active
  end
end
