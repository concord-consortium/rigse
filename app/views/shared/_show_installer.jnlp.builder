jnlp_headers(runnable)
session_options = request.env["rack.session.options"]
xml.instruct! :xml, :version => "1.0", :encoding => "UTF-8"
xml.jnlp(:spec => "1.0+", :codebase => jnlp_adaptor.jnlp.codebase) { 
  jnlp_information(xml)
  xml.security {
    xml << "    <all-permissions />"
  }
  jnlp_mac_java_config(xml)
  jnlp_installer_resources(xml, { :authoring => @authoring, :runnable => runnable, :wrapped_jnlp_url => wrapped_jnlp_url } )

#   <application-desc main-class="org.concord.LaunchJnlp">
#    <argument>dummy</argument>
#   </application-desc>
  xml << "  <application-desc main-class='org.concord.LaunchJnlp'>\n  "
    xml.argument polymorphic_url(runnable, :format =>  :config, :teacher_mode => teacher_mode, :session => session_options[:id])
  xml << "  </application-desc>\n"
}