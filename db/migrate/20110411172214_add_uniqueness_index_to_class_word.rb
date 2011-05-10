class AddUniquenessIndexToClassWord < ActiveRecord::Migration
  def self.up
    add_index :portal_clazzes, :class_word, :unique => true
  end

  def self.down
    remove_index :portal_clazzes, :column => :class_word
  end
end
