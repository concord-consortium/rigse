require 'open-uri'
require 'hpricot'
require 'fileutils'
require 'net/http'
require 'date'

if RUBY_PLATFORM =~ /java/
  java_import java.util.jar.JarInputStream unless defined? JarInputStream
  java_import java.io.FileInputStream unless defined? FileInputStream
  java_import java.net.URL unless defined? URL
  java_import java.util.Collection unless defined? Collection
  java_import java.util.List unless defined? List
  java_import java.util.ArrayList unless defined? ArrayList
  #
  # Used to refer to Java classes in the java.io package.
  # Some of the class names in the java.io package have the
  # same name as existing Ruby classes. This creates a namespace
  # scope for referring to the Java classes.
  #
  # Example:
  #
  #   JavaIO::File.new("dummy.txt")
  #
  module JavaIO     
    include_package "java.io"
  end
  #
  # Used to refer to Java classes in the net.sf.sail.emf.launch package.
  #
  # Example:
  #
  #   
  #
  module SailEmfLaunch
    include_package "net.sf.sail.emf.launch"
  end
  #
  # Used to refer to Java classes in the net.sf.sail.core.bundle package.
  #
  # Example:
  #
  #   bundleManager = SailCoreBundle::BundleManager.new
  #
  module SailCoreBundle
    include_package "net.sf.sail.core.bundle"
  end
  #
  # Used to refer to Java classes in the net.sf.sail.core.util.
  #
  # Example:
  #
  #   manager = serviceContext.getService(SailCoreService::SessionManager.class)
  #
  module SailCoreService
    include_package "net.sf.sail.core.service"
  end
  #
  # Used to refer to Java classes in: net.sf.sail.core.util
  #
  # Example:
  #
  #   
  #
  module SailCoreServiceImpl
    include_package "net.sf.sail.core.service.impl"
  end
  #
  # Used to refer to Java classes in: net.sf.sail.core.util
  #
  # Example:
  #
  #   
  #
  module SailCoreUtil
    include_package "net.sf.sail.core.util"
  end
end

module Jnlp #:nodoc:
  # 
  #
  # Jnlp::Otrunk is a subclass of Jnlp::Jnlp that adds SAIL-Otrunk[https://confluence.concord.org/display/CSP/OTrunk]
  # specific methods for execution.of the jnlp locally without 
  # using Java Web Start.
  #
  # It assumes a default main-class of:
  #
  #   net.sf.sail.emf.launch.EMFLauncher2
  #
  # and by default uses the argument in the original jnlp.
  # Both of these values can be overridden. 
  #
  # Example:
  #
  #   j = Jnlp::Otrunk.new('http://rails.dev.concord.org/sds/2/offering/144/jnlp/540/view?sailotrunk.otmlurl=http://continuum.concord.org/otrunk/examples/BasicExamples/document-edit.otml&sailotrunk.hidetree=false', 'cache'); nil
  #
  #
  class Otrunk < Jnlp
    #
    # This will start the jnlp locally in Java without
    # using Java Web Start
    #
    # This method works in MRI by forking and using exec
    # to start a separate javavm process.
    #
    #
    # JRuby Note:
    #
    # In JRuby the jars are required which makes them available
    # to JRuby -- but to make this work you will need to also 
    # included them on the CLASSPATH.
    #
    # The convienence method Jnlp#write_local_classpath_shell_script
    # can be used to create a shell script to set the classpath.
    # 
    # If you are using the JRuby interactive console you will need to
    # exclude any reference to a separate jruby included in the jnlp.
    #
    # Example in JRuby jirb:
    #
    #   j = Jnlp::Otrunk.new('http://rails.dev.concord.org/sds/2/offering/144/jnlp/540/view?sailotrunk.otmlurl=http://continuum.concord.org/otrunk/examples/BasicExamples/document-edit.otml&sailotrunk.hidetree=false', 'cache'); nil
    #   j.write_local_classpath_shell_script('document-edit_classpath.sh', :remove_jruby => true)
    #
    # Now exit jirb and execute this in the shell:
    #
    #   source document-edit_classpath.sh
    #
    # Now restart jirb:
    #
    #   j = Jnlp::Otrunk.new('http://rails.dev.concord.org/sds/2/offering/144/jnlp/540/view?sailotrunk.otmlurl=http://continuum.concord.org/otrunk/examples/BasicExamples/document-edit.otml&sailotrunk.hidetree=false', 'cache'); nil
    #   j.run_local
    #
    # You can optionally pass in jnlp and main-class arguments
    # If these paramaters are not present Otrunk#run_local will 
    # use:
    #
    #   net.sf.sail.emf.launch.EMFLauncher2
    #
    # as the default main class and the default argument in 
    # the original jnlp.
    #
    def run_local(argument=@argument, main_class='net.sf.sail.emf.launch.EMFLauncher2')
      if RUBY_PLATFORM =~ /java/
        
        java.lang.Thread.currentThread.setContextClassLoader(JRuby.runtime.jruby_class_loader)
        
        require_resources
        configUrl = URL.new(JavaIO::File.new("dummy.txt").toURL, argument) 
        # configUrl = URL.new("document-edit.config")  
        unless @bundleManager
          @bundleManager = SailCoreBundle::BundleManager.new
          @serviceContext = @bundleManager.getServiceContext
          @bundleManager.setContextURL(configUrl)
          # 
          # Add the <code>bundles</code> configured in this bundles xml file. The format of the file
          # is XMLEncoder
          # 
          @bundleManager.addBundles(configUrl.openStream)
          # 
          # Have all the bundles register their services, and then do any linking
          # to other registered services
          # 
          @bundleManager.initializeBundles
          # 
          # Start the session manager
          # 
          @manager = @serviceContext.getService(SailCoreService::SessionManager.java_class)
        end
        @manager.start(@serviceContext)
      else
        command = "java -classpath #{local_classpath} #{main_class} '#{argument}'"
        $pid = fork { exec command }
      end
    end
    #
    # This will stop the locally run OTrunk process.
    # This only works in MRI at this point.
    #
    def stop_local
      if RUBY_PLATFORM =~ /java/
        @manager.stop(@serviceContext)
      else
        Process.kill 15, $pid
        Process.wait($pid)
      end
    end
  end
end
