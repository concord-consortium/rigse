module InvestigationsHelper
  
  def updated_time_text(investigation)
    format = "%m/%d/%Y %I:%M%p %Z"
    "Last updated: #{investigation.updated_at.getlocal.strftime(format)}"
  end
  
end
