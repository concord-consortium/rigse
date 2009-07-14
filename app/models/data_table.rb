class DataTable < ActiveRecord::Base

  
  belongs_to :user
  has_many :page_elements, :as => :embeddable
  has_many :pages, :through =>:page_elements
  has_many :teacher_notes, :as => :authored_entity
  
  acts_as_replicatable

  include Changeable

  self.extend SearchableModel
  
  @@searchable_attributes = %w{uuid name description column_names column_data}
  
  class <<self
    def searchable_attributes
      @@searchable_attributes
    end
  end

  default_value_for :name, "DataTable element"
  default_value_for :description, "description ..."
  default_value_for :headings, ['column a','column b','column c']
  default_value_for :column_count, 3
  default_value_for :visible_rows, 9

  send_update_events_to :investigations

  def self.record_delimiter
    ","
  end

  def headings=(heading_array)
    self.column_names = heading_array.join(DataTable.record_delimiter)
  end
  
  def headings
    return unless self.column_names
    self.column_names.split(DataTable.record_delimiter)
  end

  #
  # There are probably are better / simpler  / faster ways to pull out indecies.
  #
  def heading(col_index)
    begin
      return headings[col_index - 1]
    rescue
      logger.error "bad heading number:#{col_index}"
      logger.error $!
      return ""
    end
  end
  
  def data=(data_array)
    self.column_data = data_array.join(DataTable.record_delimiter)
  end

  def data
    return [] unless self.column_data
    column_data.split(DataTable.record_delimiter)
  end

  #
  # There are probably are faster, more efficient ways to pull out these indicies....
  #
  def cell_data(column_index,row_index)
    if column_index > column_count
      logger.error "bad cell column: Column:#{column_index}"
      return ""
    end
    index = (row_index -1) * column_count + (column_index -1)
    return data[index]
  end

  def self.display_name
    "Data Table"
  end

  def investigations
    invs = []
    self.pages.each do |page|
      inv = page.investigation
      invs << inv if inv
    end
  end

end
