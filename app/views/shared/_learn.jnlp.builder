jnlp_headers(runnable)
config_url_options = {:format => :config}
if local_assigns[:jnlp_session]
  config_url_options[:jnlp_session] = jnlp_session.token
else
  # we should really stop putting the session in the jnlp
  config_url_options[Rails.application.config.session_options[:key]] =  request.env["rack.session.options"][:id]
end
xml.instruct! :xml, :version => "1.0", :encoding => "UTF-8"
xml.jnlp(:spec => "1.0+", :codebase => jnlp_adaptor.jnlp.codebase) { 
  jnlp_information(xml, learner)
  xml.security {
    xml << "    <all-permissions />"
  }
  jnlp_mac_java_config(xml)
  if local_assigns[:data_test]
    jnlp_testing_resources(xml, { :learner => learner, :runnable => runnable })
  else
    jnlp_resources(xml, { :learner => learner, :runnable => runnable })
  end
    
  jnlp_resources_linux(xml)
  jnlp_resources_macosx(xml)
  jnlp_resources_windows(xml)
  if local_assigns[:data_test]
    xml << "  <application-desc main-class='org.concord.testing.gui.AutomatedDataEditor'>\n  "
  else
    xml << "  <application-desc main-class='net.sf.sail.emf.launch.EMFLauncher2'>\n  "
  end
  xml.argument polymorphic_url(learner, config_url_options )
  xml << "  </application-desc>\n"
}
