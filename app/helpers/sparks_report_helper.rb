module SparksReportHelper
  
  def time_str(t)
    t.localtime.strftime('%I:%M%p %b %d, %Y %Z')
  end
  
end