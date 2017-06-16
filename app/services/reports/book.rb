# thin wrapper around AXLSX so it might be easier to test and replace
class Reports::Book
  attr_accessor :sheets
  attr_reader :mime_type
  attr_reader :file_extension

  def initialize(options={})
    @sheets = []
    @mime_type = "application/vnd.ms.excel"
    @file_extension = "xlsx"
    @verbose = options[:verbose]
  end

  def create_worksheet(_options)
    options = _options.merge(verbose: @verbose)
    sheet = Reports::Sheet.new(options)
    @sheets << sheet
    sheet
  end

  def to_axlsx_package
    package = Axlsx::Package.new
    book = package.workbook
    @sheets.each{|sheet|
      sheet.add_to_book(book)
    }
    package
  end

  def to_data_string
    to_axlsx_package.to_stream.string
  end

  def save(filename)
    to_axlsx_package.serialize(filename)
  end

end
