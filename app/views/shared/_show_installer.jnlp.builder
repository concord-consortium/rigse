jnlp_headers(runnable)
session_options = request.env["rack.session.options"]
xml.instruct! :xml, :version => "1.0", :encoding => "UTF-8"
# hard code the codebase because the jar file versions are also hardcoded
xml.jnlp(:spec => "1.0+", :codebase => "http://jnlp.concord.org/dev3") { 
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