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
  jnlp_installer_resources(xml, {:learner => learner, :runnable => runnable, :wrapped_jnlp_url => wrapped_jnlp_url } )

  xml << "  <application-desc main-class='org.concord.LaunchJnlp'>\n  "
  xml.argument polymorphic_url(learner, :format =>  :config, :session => session_options[:id])
  xml << "  </application-desc>\n"
}