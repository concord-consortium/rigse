class AddDataTableIdToEmbeddableDataCollector < ActiveRecord::Migration
  def self.up
    add_column :embeddable_data_collectors, :data_table_id, :integer
    Embeddable::DataTable.find(:all).each do |dt|
      unless dt.data_collector_id.nil?
        collector = Embeddable::DataCollector.find(dt.data_collector_id)
        if collector
          collector.data_table_id = dt.id
          collector.save
          puts "inverted one data table <-> data collector relationship"
        end
      end
    end
  end

  def self.down
    Embeddable::DataCollector.find(:all).each do |dc|
      unless dc.data_table_id.nil?
        table = Embeddable::DataTable.find(dc.data_table_id)
        if table
          if table.data_collector_id != dc.id
            table.data_collector_id = dc.id
            table.save
            puts "reverted one data table <-> data collector relationship"
          end
        end
      end
    end
    remove_column :embeddable_data_collectors, :data_table_id
  end
end
