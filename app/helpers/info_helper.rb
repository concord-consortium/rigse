module InfoHelper
  def info_button(description_id,text="view more info")
    results = <<-EOD
      <a href    = "#" 
         onclick = "$('#{description_id}').toggle(); if (window.event) event.returnValue=false; return false;"
         title   = "View activity description">
    EOD
    results << image_tag('diy_icons/information.png')
    results << "</a>"
  end
end
