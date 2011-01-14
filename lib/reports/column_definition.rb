class Reports::ColumnDefinition
  require 'spreadsheet'

  attr_accessor :title, :width, :left_border, :right_border, :top_border, :bottom_border

  def initialize(opts = {})
    @title = opts[:title] || 'Title'
    @width = opts[:width] || 12
    @left_border = !!opts[:left_border]
    @top_border = !!opts[:top_border]
    @right_border = !!opts[:right_border]
    @bottom_border = !!opts[:bottom_border]
  end

  def write_header(sheet)
    # recalculate the formats just in case they've changed between now and when the instance was created
    @title_format = Spreadsheet::Format.new :weight => :bold, :left => @left_border, :right => @right_border, :top => @top_border, :bottom => @bottom_border
    @column_format = Spreadsheet::Format.new :left => @left_border, :right => @right_border, :top => @top_border, :bottom => @bottom_border

    col_idx = sheet.column_count
    sheet[0, col_idx] = @title
    sheet.row(0).set_format(col_idx, @title_format)
    sheet.column(col_idx).width = @width
    sheet.column(col_idx).default_format = @column_format
  end
end
