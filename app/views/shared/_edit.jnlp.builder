jnlp_headers(runnable)
session_options = request.env["rack.session.options"]
xml.instruct! :xml, :version => "1.0", :encoding => "UTF-8"
xml.jnlp(:spec => "1.0+", :codebase => jnlp_adaptor.jnlp.codebase) { 
  jnlp_information(xml)
  xml.security {
    xml << "    <all-permissions />"
  }
  jnlp_mac_java_config(xml)
  jnlp_resources(xml, { :authoring => @authoring, :runnable => runnable, :action => :edit })
  jnlp_resources_linux(xml)
  jnlp_resources_macosx(xml)
  jnlp_resources_windows(xml)

  xml << "  <application-desc main-class='net.sf.sail.emf.launch.EMFLauncher2'>\n  "
  xml.argument polymorphic_url(runnable, :format =>  :config, :teacher_mode => teacher_mode, :session => session_options[:id], :action => :edit)
  xml << "  </application-desc>\n"
}