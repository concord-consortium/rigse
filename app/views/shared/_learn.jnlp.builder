response.headers["Content-Type"] = "application/x-java-jnlp-file"
response.headers["Cache-Control"] = "max-age=1"
response.headers["Last-Modified"] = runnable.updated_at.httpdate
response.headers["Content-Disposition"] = "inline; filename=RITES_#{runnable.class.name.underscore}_#{short_name(runnable.name)}.jnlp"
session_options = request.env["rack.session.options"]

xml.instruct! :xml, :version => "1.0", :encoding => "UTF-8"
xml.jnlp(:spec => "1.0+", :codebase => @jnlp_adaptor.jnlp.codebase) { 
  xml.information { 
    xml.title "CC OTrunk Application"
    xml.vendor "Created by the Concord Consortium"
    xml.homepage :href => "http://confluence.concord.org/display/TMS/OTrunk+Examples"
    xml.description "CC OTrunk Application built on SAIL"
    xml.icon :href => full_url_for_image("sail_orangecirc_64.gif"), :height => "64", :width => "64"
  }
  xml.security {
    xml << "    <all-permissions />"
  }
  # Force Mac OS X to use Java 1.5 so that sensors are ensured to work
  xml.resources(:os => "Mac OS X") {
    xml.j2se :version => "1.5", :"max-heap-size" => "128m", :"initial-heap-size" => "32m"
  }
  if defined? data_test && data_test
    jnlp_resources(xml, { :learner => learner, :runnable => runnable, :data_test => data_test})
  else
    jnlp_resources(xml, { :learner => learner, :runnable => runnable})
  end
    
  jnlp_resources_linux(xml)
  jnlp_resources_macosx(xml)
  jnlp_resources_windows(xml)
  if defined? data_test && data_test
    xml << "  <application-desc main-class='org.concord.testing.gui.AutomatedDataEditor'>"
  else
    xml << "  <application-desc main-class='net.sf.sail.emf.launch.EMFLauncher2'>\n"
  end
  xml.argument polymorphic_url(learner, :format =>  :config, :session => session_options[:id])
  xml << "  </application-desc>\n"
}