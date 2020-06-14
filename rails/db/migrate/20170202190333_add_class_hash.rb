class AddClassHash < ActiveRecord::Migration
  def up
    add_column :portal_clazzes, :class_hash, :string, :limit => 48

    Portal::Clazz.where(class_hash: nil).find_each(batch_size: 100) do |portal_clazz|
      portal_clazz.generate_class_hash
      portal_clazz.save!
    end
  end

  def down
    remove_column :portal_clazzes, :class_hash
  end
end

