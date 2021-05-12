class AddIgnoreFlagToReportEmbeddableFilter < ActiveRecord::Migration[5.1]
  def self.up
    add_column :report_embeddable_filters, :ignore, :boolean
  end

  def self.down
    remove_column :report_embeddable_filters, :ignore
  end
end
