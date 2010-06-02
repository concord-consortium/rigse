module Sparks::ReportHelper
  
  def time_str(t)
    t.localtime.strftime('%I:%M%p %b %d, %Y %Z')
  end
  
  def time_str_short(t)
    t.localtime.strftime('%I:%M%p %m/%d/%y')
  end
  
  def time_from_ms(milliseconds)
    s, ms = milliseconds.divmod(1000)
    micro_sec = ms / 1000
    Time.at(s, micro_sec)
  end
  
  def chart(xs)
    html = '<img src="http://chart.apis.google.com/chart?cht=lc&chs=110x80&chma=8,8,4,4'
    html << "&chd=t:#{xs.join(',')}"
    html << '" />'
    html
  end
  
end
