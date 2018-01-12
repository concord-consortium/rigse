class Reports::ColumnDefinition
  attr_accessor :title, :width, :left_border, :right_border, :top_border, :bottom_border, :col_index

  def initialize(opts = {})
    @title = opts[:title] || 'Title'
    @col_index = opts[:col_index]
    @heading_row = opts[:heading_row] || 1 # allow for one additional row above
  end

  def write_header(sheet)
    @col_index ||= sheet.row(@heading_row).length
    sheet.row(@heading_row)[@col_index] = @title
  end
end
