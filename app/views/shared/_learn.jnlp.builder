jnlp_headers(runnable)
session_options = request.env["rack.session.options"]
xml.instruct! :xml, :version => "1.0", :encoding => "UTF-8"
xml.jnlp(:spec => "1.0+", :codebase => jnlp_adaptor.jnlp.codebase) { 
  jnlp_information(xml)
  xml.security {
    xml << "    <all-permissions />"
  }
  jnlp_mac_java_config(xml)
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
  xml.argument polymorphic_url(learner, :format =>  :config,  Rails.application.config.session_options[:key]  => session_options[:id])
  xml << "  </application-desc>\n"
}