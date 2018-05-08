class DropEmbeddableTables < ActiveRecord::Migration
  def remove_table(name)
    drop_table name.to_sym if ActiveRecord::Base.connection.tables.include?(name)
  end

  def up
    [
      "embeddable_data_collectors",
      "embeddable_data_tables",
      "embeddable_drawing_tools",
      "embeddable_inner_pages",
      "embeddable_inner_page_pages",
      "embeddable_lab_book_snapshots",
      "embeddable_mw_modeler_pages",
      "embeddable_n_logo_models",
      "embeddable_raw_otmls",
      "embeddable_smartgraph_range_questions",
      "embeddable_sound_graphers",
      "embeddable_video_players",
      "embeddable_xhtmls"
    ].each { |table| self.remove_table(table) }

    [
      "Embeddable::DataCollector",
      "Embeddable::DataTable",
      "Embeddable::DrawingTool",
      "Embeddable::InnerPage",
      "Embeddable::InnerPagePage",
      "Embeddable::LabBookSnapshot",
      "Embeddable::MwModelerPage",
      "Embeddable::NLogoModel",
      "Embeddable::RawOtml",
      "Embeddable::Smartgraph::RangeQuestion",
      "Embeddable::SoundGrapher",
      "Embeddable::VideoPlayer",
      "Embeddable::Xhtml"
    ].each do |embeddableType|
      execute "delete from saveable_external_links where embeddable_type like '%#{embeddableType}%'"
      execute "delete from page_elements where embeddable_type like '%#{embeddableType}%'"
      execute "delete from portal_offering_embeddable_metadata where embeddable_type like '%#{embeddableType}%'"
    end

  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
