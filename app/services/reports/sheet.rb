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
    book.add_worksheet(name: @name){|x_sheet|
      @rows.each{|row|
        puts " Adding row: #{row}" if @verbose
        if row.nil?
          x_sheet.add_row
        else
          x_sheet.add_row row
        end
      }
    }
  end

end
