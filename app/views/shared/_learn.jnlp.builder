jnlp_headers(runnable)
session_options = request.env["rack.session.options"]
xml.instruct! :xml, :version => "1.0", :encoding => "UTF-8"
xml.jnlp(:spec => "1.0+", :codebase => @jnlp_adaptor.jnlp.codebase) { 
  jnlp_information(xml)
  xml.security {
    xml << "    <all-permissions />"
  }
  # Force Mac OS X to use Java 1.5 so that sensors are ensured to work
  xml.resources(:os => "Mac OS X", :arch => "ppc i386") {
    xml.j2se :version => "1.5", :"max-heap-size" => "128m", :"initial-heap-size" => "32m"
  }
  xml.resources(:os => "Mac OS X", :arch => "x86_64") {
    xml.j2se :version => "1.5", :"max-heap-size" => "128m", :"initial-heap-size" => "32m", :"java-vm-args" => "-d32"
  }
  if defined? data_test && data_test
    jnlp_testing_resources(xml, { :learner => learner, :runnable => runnable })
  else
    jnlp_resources(xml, { :learner => learner, :runnable => runnable })
  end
    
  jnlp_resources_linux(xml)
  jnlp_resources_macosx(xml)
  jnlp_resources_windows(xml)
  if defined? data_test && data_test
    xml << "  <application-desc main-class='org.concord.testing.gui.AutomatedDataEditor'>\n  "
  else
    xml << "  <application-desc main-class='net.sf.sail.emf.launch.EMFLauncher2'>\n  "
  end
  xml.argument polymorphic_url(learner, :format =>  :config, :session => session_options[:id])
  xml << "  </application-desc>\n"
}