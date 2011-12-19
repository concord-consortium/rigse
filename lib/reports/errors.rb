module Reports::Errors
  class GeneralReportError < StandardError
  end

  class TooManyCellsError < GeneralReportError
  end

  class TooManySheetsError < GeneralReportError
  end
end
