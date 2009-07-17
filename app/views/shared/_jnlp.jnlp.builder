response.headers["Content-Type"] = "application/x-java-jnlp-file"
response.headers["Cache-Control"] = "max-age=1"
response.headers["Last-Modified"] = runnable_object.updated_at.httpdate
response.headers["Content-Disposition"] = "inline; filename=RITES_#{runnable_object.class.name.underscore}_#{short_name(runnable_object.name)}.jnlp"

xml.instruct! :xml, :version => "1.0", :encoding => "UTF-8"
xml.jnlp(:spec => "1.0+", :codebase => jnlp_adaptor.jnlp.codebase) { 
  xml.information { 
    xml.title "CC OTrunk Application"
    xml.vendor "Created by the Concord Consortium"
    xml.homepage :href => "http://confluence.concord.org/display/TMS/OTrunk+Examples"
    xml.description "CC OTrunk Application built on SAIL"
    xml.icon :href => path_to_image("sail_orangecirc_64.gif"), :height => "64", :width => "64"
  }
  xml.security {
    xml << "    <all-permissions />"
  }
  jnlp_resources(xml, { :authoring => @authoring, :runnable_object => runnable_object})
  jnlp_resources_linux(xml)
  jnlp_resources_macosx(xml)
  jnlp_resources_windows(xml)

  xml << "  <application-desc main-class='net.sf.sail.emf.launch.EMFLauncher2'>\n"
  xml.argument "http://saildataservice.concord.org/2/offering/144/config/540/0/view?sailotrunk.hidetree=false&amp;sailotrunk.otmlurl=#{escaped_otml_url}"
  xml << "  </application-desc>\n"
}