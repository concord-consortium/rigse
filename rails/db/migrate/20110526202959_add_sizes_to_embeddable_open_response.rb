class AddSizesToEmbeddableOpenResponse < ActiveRecord::Migration
  def self.up
    add_column :embeddable_open_responses, :rows,      :integer, :default => 5
    add_column :embeddable_open_responses, :columns,   :integer, :default => 32
    add_column :embeddable_open_responses, :font_size, :integer, :default => 12
  end

  def self.down
    remove_column :embeddable_open_responses, :columns
    remove_column :embeddable_open_responses, :rows
    remove_column :embeddable_open_responses, :font_size
  end
end
