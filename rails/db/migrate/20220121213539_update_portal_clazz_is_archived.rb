class UpdatePortalClazzIsArchived < ActiveRecord::Migration[6.1]
  module Portal
  end

  class Portal::Clazz < ApplicationRecord
    self.table_name = :portal_clazzes
  end
  class Portal::TeacherClazz < ApplicationRecord
    self.table_name = :portal_teacher_clazzes
  end

  def change
    Portal::TeacherClazz.find_each(batch_size: 100) do |tc|
      Portal::Clazz.where(id: tc.clazz_id).update_all(is_archived: !tc.active)
    end
  end
end
