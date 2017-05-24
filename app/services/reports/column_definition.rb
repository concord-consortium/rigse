class Reports::ColumnDefinition
  require 'spreadsheet'

  attr_accessor :title, :width, :left_border, :right_border, :top_border, :bottom_border, :col_index

  def initialize(opts = {})
    @title = opts[:title] || 'Title'
    @width = opts[:width] || 12
    @left_border = opts[:left_border] || :none
    @top_border = opts[:top_border] || :none
    @right_border = opts[:right_border] || :none
    @bottom_border = opts[:bottom_border] || :none
    @col_index = opts[:col_index]
    @heading_row = opts[:heading_row] || 1 # allow for one additional row above
  end

  def write_header(sheet)
    # recalculate the formats just in case they've changed between now and when the instance was created
    @title_format = Spreadsheet::Format.new :weight => :bold, :left => @left_border, :right => @right_border, :top => @top_border, :bottom => @bottom_border
    @column_format = Spreadsheet::Format.new :left => @left_border, :right => @right_border, :top => @top_border, :bottom => @bottom_border

    @col_index ||= sheet.column_count  # allow to manually set the column index
    sheet[@heading_row, @col_index] = @title
    sheet.row(@heading_row).set_format(@col_index, @title_format)
    sheet.column(@col_index).width = @width
    sheet.column(@col_index).default_format = @column_format
  end
end
