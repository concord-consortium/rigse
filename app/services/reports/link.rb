# This Link object that can be added to a row in a spreadsheet.
# when it is serialized then it will be turned into a link in a way compatible with
# the spreadsheet library (currently axlsx)
class Reports::Link
  attr_accessor :url
  attr_accessor :text

  def initialize(options)
    @url = options[:url]
    @text = options[:text]
  end
end
