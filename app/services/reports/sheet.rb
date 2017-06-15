# Simple abstraction on top of spreadsheet library
# Currently the whole sheet is stored in memory twice.
# We could optimize this to work directly with the axlsx obects, but it would require
# further abstraction of the row objects. Right now the rows are just arrays.
class Reports::Sheet
  attr_reader :rows
  attr_accessor :name

  def initialize(options)
    @rows = []
    @name = options[:name] || "Sheet Name"
    @verbose = options[:verbose]
  end

  def row(index)
    @rows[index] ||= []
  end

  def last_row_index
    @rows.length - 1
  end

  # axlsx specific stuff
  def add_to_book(book)
    puts "Adding sheet: #{@name}" if @verbose
    book.add_worksheet(name: @name) do |x_sheet|
      @rows.each do |row|
        puts " Adding row: #{row}" if @verbose
        x_row = x_sheet.add_row
        next if row.nil?
        row.each do |cell|
          if cell.is_a? Reports::Link
            x_cell = x_row.add_cell cell.text
            x_sheet.add_hyperlink :location => cell.url, :ref => x_cell
          else
            x_row.add_cell cell
          end
        end
      end
    end
  end

end
