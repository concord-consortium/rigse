class AddIgnoreFlagToReportEmbeddableFilter < ActiveRecord::Migration
  def self.up
    add_column :report_embeddable_filters, :ignore, :boolean
  end

  def self.down
    remove_column :report_embeddable_filters, :ignore
  end
end
