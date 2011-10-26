class AddUniquenessIndexToClassWord < ActiveRecord::Migration
  def self.up
    remove_index :portal_clazzes, :column => :class_word
    add_index :portal_clazzes, :class_word, :unique => true
  end

  def self.down
    # this migration ensures that the class word is a unique index
    # A previous migration added the index, so we dont remove it here.
    # remove_index :portal_clazzes, :column => :class_word
  end
end
