class DataTable < ActiveRecord::Base

  
  belongs_to :user
  has_many :page_elements, :as => :embeddable
  has_many :pages, :through =>:page_elements
  has_many :teacher_notes, :as => :authored_entity
  
  acts_as_replicatable

  include Changeable

  self.extend SearchableModel
  
  @@searchable_attributes = %w{name description}
  
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


  def self.row_delimiter
    "\n"
  end

  def self.column_delimiter
    ","
  end

  def headings=(heading_array)
    self.column_names = heading_array.join(DataTable::column_delimiter)
  end

  def data=(data_array)
    text = ""
    data_array.each do |row|
      text << row.join(DataTable::column_delimiter) << DataTable::row_delimiter
    end
    self.column_data = text
  end
  
  def headings
    return unless self.column_names
    self.column_names.split(DataTable::column_delimiter)
  end
  
  def data
    return unless self.column_data
    column_data.split(DataTable::row_delimiter).map { |row| row.split(DataTable::column_delimiter) }
  end

  #
  # There are probably are faster, more efficient ways to pull out these indicies....
  #
  def cell_data(row_index,column_index)
    begin
      return data[row_index-1][column_index-1]
    rescue
      logger.error "bad cell number: Row:#{row_index}, Column:#{column_index}"
      logger.error $!
      return ""
    end
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


  def self.display_name
    "Data Table"
  end


end
