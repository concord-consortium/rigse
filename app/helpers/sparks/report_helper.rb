module Sparks::ReportHelper
  
  def time_str(t)
    t.localtime.strftime('%I:%M%p %b %d, %Y %Z')
  end
  
  def time_from_ms(milliseconds)
    s, ms = milliseconds.divmod(1000)
    micro_sec = ms / 1000
    Time.at(s, micro_sec)
  end
  
end
