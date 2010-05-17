require 'rubygems'
require 'open-uri'
require 'hpricot'
require 'fileutils'
require 'net/http'
require 'date'

if RUBY_PLATFORM =~ /java/
  include Java
  java_import java.util.jar.JarInputStream unless defined? JarInputStream
  java_import java.io.FileInputStream unless defined? FileInputStream
  java_import java.net.URL unless defined? URL
end

unless Net::HTTP::Get.new('/')['User-Agent'] # unless a 'User-Agent' is already defined add one
  #
  # Monkey patch Net::HTTP so it always provides a User-Agent
  # if the request doesn't already specify one.
  #
  # This compensates for a bug in Tomcat/webstart servers which
  # throw a 500 error for requests w/o a User-Agent header.
  #
  class Net::HTTPGenericRequest
    include Net::HTTPHeader
    def initialize(m, reqbody, resbody, path, initheader = nil)
      @method = m
      @request_has_body = reqbody
      @response_has_body = resbody
      raise ArgumentError, "HTTP request path is empty" if path.empty?
      @path = path
      initialize_http_header initheader
      self['Accept'] ||= '*/*'
      self['User-Agent'] ||= 'Ruby' # this is the new line
      @body = nil
      @body_stream = nil
    end
  end
end

module Jnlp #:nodoc:
  #  
  # Property objects encapsulate <property> elements present in a
  # Java Web Start Jnlp <resources> element.
  #
  class Property
    #
    # Contains the Hpricot element parsed from the orginal Jnlp
    # that was used to create the Property
    #
    attr_reader :property
    #
    # Contains the name of the Property
    #
    #
    # Example:
    #
    #   "maven.jnlp.version"
    #
    attr_reader :name
    #
    # Contains the value of the Property
    #
    #
    # Example:
    #
    #   "all-otrunk-snapshot-0.1.0-20080310.211515"
    #
    attr_reader :value
    #
    # Contains the value of the os attribute in the 
    # parent <resources> element that contains this property 
    # if the attribute was set in the parent.
    # Example: 
    #
    #   "Mac OS X"
    #
    attr_reader :os
    #
    # Creates a new Jnlp::Property object.
    # * _prop_: the Hpricot parsing of the specific jnlp/resources/property element
    # * _os_: optional: include it if the resources parent element that contains the property has this attribute set
    #
    def initialize(prop, os=nil)
      @property = prop
      @name = prop['name']
      @value = prop['value']
      @os = os
    end
  end

  class J2se
    #
    # Contains the Hpricot element parsed from the orginal Jnlp
    # that was used to create the Property
    #
    attr_reader :j2se
    #
    # Contains the version of the J2SE element:
    #
    # Example:
    #
    #   "1.5+"
    #
    attr_reader :version
    #
    # Contains the max-heap-size specified in the J2SE element:
    #
    # Example:
    #
    #   "128m"
    #
    attr_reader :max_heap_size
    #
    # Contains the initial-heap-size specified in the J2SE element:
    #
    # Example:
    #
    #   "32m"
    #
    attr_reader :initial_heap_size
    #
    # Contains the value of the optional java-vm-args attribute in
    # in the J2SE element, the value is nil if not present:
    # 
    # Example:
    #
    #   "-d32"
    #
    attr_reader :java_vm_args
    #
    # Contains the value of the os attribute in the 
    # parent <resources> element that contains this property 
    # if the attribute was set in the parent. The attribute is normalized
    # by converting to lowercase and changing ' ' characters to '_'
    #
    # Example: 
    #
    #   "Mac OS X" => "mac_os_x"
    #
    attr_reader :os
    #
    # Contains the value of the arch attribute in the 
    # parent <resources> element that contains this property 
    # if the attribute was set in the parent.The attribute is normalized
    # by converting to lowercase and changing ' ' characters to '_'
    #
    # Examples: 
    #
    #   "ppc i386" => "ppc_i386"
    #   "x86_64"   => "x86_64"
    #
    attr_reader :arch
    #
    # Creates a new Jnlp::Property object.
    # * _prop_: the Hpricot parsing of the specific jnlp/resources/property element
    # * _os_: optional: include it if the resources parent element that contains the property has this attribute set
    #
    def initialize(j2se, os=nil, arch=nil)
      @j2se = j2se
      @version = j2se['version']
      @max_heap_size = j2se['max-heap-size']
      @initial_heap_size = j2se['initial-heap-size']
      @java_vm_args = j2se['java-vm-args']
      @os = os
      @arch = arch
    end
  end

  #
  # Icon objects encapsulate the <icon> element optionally present in
  # the Java Web Start jnlp <information> element.
  #
  class Icon
    #
    # Contains the Hpricot element parsed from the orginal Jnlp
    # that was used to create the Icon
    #
    attr_reader :icon    
    #
    # Contains the href attribute of the <icon> element.
    #
    # Example:
    #
    #   "http://itsi.concord.org/images/itsi-logo-64x64.png"
    #
    attr_reader :href
    #
    # Contains the height attribute of the <icon> element
    #
    # Example:
    #
    #   64
    #
    attr_reader :height
    #
    # Contains the width attribute of the <icon> element
    #
    # Example:
    #
    #   64
    #
    attr_reader :width
    #
    # Creates a new Icon object
    # * _icon_: pass in a Hpricot parse of the <icon> element
    #
    def initialize(icon)
      @icon = icon
      @href = icon.attr('href')
      @height = icon.attr('height').to_i
      @width = icon.attr('width').to_i
    end
  end
  #
  # Jnlp::Resource objects encapsulate both jar and nativelib elements present in a 
  # Java Web Start Jnlp <resources> element.
  #
  class Resource
    #
    # Contains the Hpricot element parsed from the orginal Jnlp
    # that was used to create the resource
    #
    attr_reader :resource
    #
    # Contains the path to the resource taken from the href attribute
    #
    # Example:
    #
    #   "org/concord/httpclient/" || ""
    #
    attr_reader :href_path
    #
    # Contains the kind of the resource
    #
    # Example:
    #
    #   "jar" || "nativelib"
    #
    attr_reader :kind
    #
    # Contains the base name of the resource
    #
    # Example:
    #
    #   "httpclient"
    #
    attr_reader :name
    #
    # Contains the Java Web Start specification of the OS for 
    # the <resources> parent of this resource if the attribute
    # value exists
    #
    # Example:
    #
    #   ""
    #
    attr_reader :os
    #
    # Contains the href attribute of the resource
    #
    # Example:
    #
    #   "net/sf/sail/webstart-proxy/jetty-proxy/jetty-proxy.jar"
    #
    attr_reader :main
    #
    # Contains a boolean that repesents whether the main_class for this
    # jnlp is contained within this jar.
    # This attribute is optional in a jnlp and if present should 
    # only be present and set to true on one jar resource in a jnlp.
    #
    attr_reader :href
    #
    # Contains the url reference to the resource
    #
    # Example:
    #
    #   "http://jnlp.concord.org/dev/org/concord/httpclient/httpclient.jar?version-id=0.1.0-20071212.220020-17"
    #
    attr_reader :url
    #
    # Contains the url reference to the gzipped pack200 version of the resource
    #
    # Example:
    #
    #   "http://jnlp.concord.org/dev/org/concord/httpclient/httpclient__V0.1.0-20071212.220020-17.jar.pack.gz"
    #
    attr_reader :url_pack_gz 
    #
    # Contains the filename of the resource
    #
    # Example:
    #
    #   "httpclient__V0.1.0-20071212.220020-17.jar"
    #
    attr_reader :suffix
    #
    # Contains the suffix of the resource
    #
    # Example:
    #
    #   "__V0.1.0.jar"
    #
    attr_reader :filename
    #
    # Contains the filename of the gzipped pack200 version of the resource
    #
    # Example:
    #
    #   "httpclient__V0.1.0-20071212.220020-17.jar.pack.gz"
    #
    attr_reader :filename_pack
    #
    # Contains the filename of the pack200 version of the resource
    #
    # Example:
    #
    #   "httpclient__V0.1.0-20071212.220020-17.jar.pack"
    #
    attr_reader :filename_pack_gz
    #
    # Contains the size of the resource
    #
    # Example:
    #
    #   294248
    #
    attr_reader :size
    #
    # Contains the size of the gzipped pack200 version of the resource
    #
    # Example:
    #
    #   112213
    #
    attr_reader :size_pack_gz
    #
    # Contains boolean value indicating whether the signature of the
    # cached local copy of the resource verified successfully
    #
    # The value is nil if no local cache has been created.
    #
    # Example:
    #
    #   true || false || nil
    #
    attr_reader :signature_verified
    #
    # Contains the absolute local path of cache directory
    #
    # Example:
    #
    #   "/Users/stephen/dev/jetty-jnlp-proxy/cache"
    #
    attr_reader :local_cache_dir
    #
    # Contains the relative local path of the resource
    #
    # Example:
    #
    #   "net/sf/sail/webstart-proxy/jetty-proxy/jetty-proxy__V0.1.0-20080318.093629-72.jar"
    #
    attr_reader :relative_local_path
    #
    # Contains the absolute local path of the resource
    #
    # Example:
    #
    #   "/Users/stephen/dev/jetty-jnlp-proxy/cache/net/sf/sail/webstart-proxy/jetty-proxy/jetty-proxy__V0.1.0-20080318.093629-72.jar"
    #
    attr_reader :local_path
    #
    # Contains the relative local path of the resource
    #
    # Example:
    #
    #   "net/sf/sail/webstart-proxy/jetty-proxy/jetty-proxy__V0.1.0-20080318.093629-72.jar.pack.gz"
    #
    attr_reader :relative_local_path_pack_gz
    #
    # Contains the absolute local path of the resource
    #
    # Example:
    #
    #   "/Users/stephen/dev/jetty-jnlp-proxy/cache/net/sf/sail/webstart-proxy/jetty-proxy/jetty-proxy__V0.1.0-20080318.093629-72.jar.pack.gz"
    #
    attr_reader :local_path_pack_gz
    #
    # Contains the version string of the resource
    #
    # Example:
    #
    #   "0.1.0-20080318.093629-72"
    #
    attr_reader :version_str
    #
    # Contains the version of the resource
    #
    # Example:
    #
    #   "0.1.0"
    #
    attr_reader :version
    #
    # Contains the date string of the resource
    #
    # Example:
    #
    #   "20080318.093629"
    #
    attr_reader :date_str
    #
    # Contains a Ruby DateTime object representation of the resource's date string 
    #
    # Example:
    #
    #   #<DateTime: 85338394589/86400,0,2299161>
    #
    attr_reader :date_time
    #
    # Contains the revision of the resource
    #
    # Example:
    #
    #   72
    #
    attr_reader :revision
    #
    # Contains the certificate version of the resource
    # if one exists, otherwize it is nil
    #
    # Example:
    #
    #   "s1"
    #
    attr_reader :certificate_version
    #
    def initialize(res, codebase, os)
      @resource = res
      @kind = res.name
      @main = res['main'] && res['main'] == 'true'
      @href = res['href']
      @href_path = File.dirname(@href)
      if @href_path == '.'
        @href_path = ''
      else
        @href_path = @href_path + '/'
      end
      @name = File.basename(@href).chomp('.jar')
      @version_str = res['version']
      if @version_str
        @suffix = "__V#{@version_str}.jar"
      else
        @suffix = ".jar"        
      end
      @filename = "#{@name}#{@suffix}"
      @filename_pack = @filename + ".pack"
      @filename_pack_gz = @filename_pack + ".gz"

      @url = "#{codebase}/#{@href_path}#{@name}.jar"
      @url << "?version-id=#{@version_str}" if @version_str
      # example: data-util__V0.1.0-20070926.155656-107.jar.pack
      # @url_pack = "#{codebase}/#{@href_path}#{@filename}.pack"
      # example: data-util__V0.1.0-20070926.155656-107.jar.pack.gz
      @url_pack_gz = "#{codebase}/#{@href_path}#{@filename}.pack.gz"
      @version, @revision, @date_str, @date_time, @certificate_version = parse_version_str(@version_str)
      @os = os
    end
    #
    # parse_version_str
    #
    # input examples:
    # 
    #  "0.1.0-20070926.155656-107"
    #
    # or a newer example:
    #
    #  "0.1.0-20090618.143130-890-s1"
    #
    # but ... some version strings just look like this:
    # 
    #  "0.1.0"
    #
    # or this:
    #
    #  "2.1.7-r2"
    #
    # results:
    #
    # version                # => '0.1.0'
    # revision               # => 20
    # date_str               # => '20070926.155656'
    # date_time              # => #<DateTime: 10673317777/10800,0,2299161>
    # certificate_version    # => 's1'
    #
    def parse_version_str(version_str)      
      version = date_str = certificate_version = ''
      revision = date_time = nil
      if version_str && version_str.length > 0
        if md = version_str.match(/(\d|\.)+/)
          version = md[0]
          # date_str
          if md2 = md.post_match.match(/-([\d]{8}.[\d]{6})(-|$)/)
            date_str = md2[1]
            d, t = date_str.scan(/\d+/)              # => ["20070926", "155656"]
            d1 = "#{d[0..3]}-#{d[4..5]}-#{d[6..7]}"   # => "2007-09-26"
            t1 = "#{t[0..1]}:#{t[2..3]}:#{t[4..5]}"   # => "15:56:56"
            dt = "#{d1}T#{t1}Z"                      # => "2007-09-26T15:56:56Z"
            date_time = DateTime.parse(dt)           # => #<DateTime: 10673317777/10800,0,2299161>
            # revision
            if md3 = md2.post_match.match(/\d+/)
              revision = md3[0].to_i
            end
          else
            if match = md.post_match[/\d+/]
              revision = match.to_i
            end
          end
          # certificate_version
          if match = md.post_match[/-(s\d+)/, 1]
            certificate_version = match
          end
        end
      end
      [version, revision, date_str, date_time, certificate_version]
    end
    #
    # Set's up the local cache directory references
    #
    def local_cache_dir=(dir_path)
      @local_cache_dir = File.expand_path(dir_path)
      @relative_local_path = "#{@href_path}#{@filename}"
      @local_path = "#{@local_cache_dir}/#{@relative_local_path}"
    end
    #
    # Copies the file referenced in _source_ to _destination_
    # _source_ can be a url or local file path
    # _destination_ must be a local path
    #
    # Will copy file if the file does not exists 
    # OR if the the file exists but the signature has
    # not been successfully verified.
    #
    # Returns file size if cached succesfully, false otherwise.
    # 
    def update_cache(source=@url, destination=@local_path)
      unless destination
        raise ArgumentError, "Must specify destination directory when updatng resource", caller
      end
      file_exists = File.exists?(destination)
      if file_exists && @signature_verified == nil
        verify_signature
      end
      unless file_exists && @signature_verified
        FileUtils.mkdir_p(File.dirname(destination))
        jarfile = open(source)
        if jarfile.class == Tempfile
          FileUtils.cp(jarfile.path, destination)
        else
          File.open(destination, 'w') {|f| f.write jarfile.read }
        end
        verify_signature ? jarfile.size : false
      else        
        File.size(destination)
      end
    end
    #
    # Verifys signature of locallly cached resource
    #
    # Returns boolean value indicating whether the signature of the
    # cached local copy of the resource verified successfully
    #
    # The value return is nil if no local cache has been created.
    #
    # Example:
    #
    #   true || false || nil
    #
    def verify_signature
      if @local_path
        if RUBY_PLATFORM =~ /java/
          begin
            jarfile = java.util.jar.JarInputStream.new(FileInputStream.new(@local_path), true)
            @signature_verified = true
          rescue NativeException
            @signature_verified = false
          end
        else
          # Use IO.popen instead of system() to absorb
          # jarsigners messages to $stdout
          response = IO.popen("jarsigner -verify #{@local_path}"){|io| io.gets}
          @signature_verified = ($?.exitstatus == 0)
        end
      else
        nil
      end
    end
    #    
    # Copies the resource referenced in Resource#url
    # to the local cache.
    #
    # If the resource is successully cached locally and the
    # signature is verified the size of the resource is retured.
    #
    # If the signature is not verified then false is returned.
    #
    def cache_resource(dest_dir=@local_cache_dir, include_pack_gz = false)
      unless dest_dir
        raise ArgumentError, "Must specify destination directory when creating resource", caller
      end
      self.local_cache_dir=dest_dir
      @size = update_cache(@url, @local_path)
      if include_pack_gz
        @relative_local_path_gz = "#{@relative_local_path_gz}.pack.gz"
        @local_path_pack_gz = "#{dest_dir}/#{@relative_local_path_pack_gz}"
        @size_pack_gz = update_cache(@url_pack_gz, @local_path_pack_gz)
      end
      @signature_verified ? @size : @signature_verified
    end
  end
  #  
  #
  # == Jnlp
  #
  # A gem for encapsulating the content and resources referenced by Java Web Start jnlps
  #
  # For more information about the structure of Java Web Start see: 
  # * http://java.sun.com/javase/6/docs/technotes/guides/javaws/developersguide/contents.html
  #
  # To create a new Jnlp call Jnlp#new with a string that contains either a local path or a url.
  #
  # Examples:
  #
  # * Creating a new Jnlp object from a local Java Web Start jnlp file.
  #   j = Jnlp::Jnlp.new("authoring.jnlp")
  # * Creating a new Jnlp object from a Java Web Start jnlp referenced with a url.
  #   j = Jnlp::Jnlp.new("http://jnlp.concord.org/dev/org/concord/maven-jnlp/otrunk-sensor/otrunk-sensor.jnlp")
  #
  # Once the Jnlp object is created you can call Jnlp#cache_resources to create a local
  # cache of all the jar and nativelib resources. The structure of the cache directory
  # and the naming using for the jar and nativelib files is the same as that used
  # by the Java Web Start Download Servlet, see: 
  # * http://java.sun.com/javase/6/docs/technotes/guides/javaws/developersguide/downloadservletguide.html
  # 
  # === Example: Creating an jnlp object and caching all the resources
  # 
  #   j = Jnlp::Jnlp.new("http://jnlp.concord.org/dev/org/concord/maven-jnlp/otrunk-sensor/otrunk-sensor.jnlp", 'web_start_cache')
  #
  # Will populate the local directory: web_start_cache with the following files:
  # 
  #   avalon-framework/avalon-framework/avalon-framework__V4.1.3.jar
  #   commons-beanutils/commons-beanutils/commons-beanutils__V1.7.0.jar
  #   commons-collections/commons-collections/commons-collections__V3.1.jar
  #   commons-digester/commons-digester/commons-digester__V1.8.jar
  #   commons-lang/commons-lang/commons-lang__V2.1.jar
  #   commons-logging/commons-logging/commons-logging__V1.1.jar
  #   commons-validator/commons-validator/commons-validator__V1.3.1.jar
  #   jdom/jdom/jdom__V1.0.jar
  #   jug/jug/jug__V1.1.2.jar
  #   log4j/log4j/log4j__V1.2.12.jar
  #   logkit/logkit/logkit__V1.0.1.jar
  #   org/apache/velocity/velocity/velocity__V1.5.jar
  #   org/apache/velocity/velocity-tools/velocity-tools__V1.3.jar
  #   org/concord/apple-support/apple-support__V0.1.0-20071207.221705-16.jar
  #   org/concord/data/data__V0.1.0-20080307.190013-90.jar
  #   org/concord/datagraph/datagraph__V0.1.0-20080306.220034-101.jar
  #   org/concord/external/ekit/ekit__V1.0.jar
  #   org/concord/external/jep/jep__V1.0.jar
  #   org/concord/external/rxtx/rxtx-comm/rxtx-comm__V2.1.7-r2.jar
  #   org/concord/external/rxtx/rxtx-serial/rxtx-serial-linux-nar__V2.1.7-r2.jar
  #   org/concord/external/rxtx/rxtx-serial/rxtx-serial-macosx-nar__V2.1.7-r2.jar
  #   org/concord/external/rxtx/rxtx-serial/rxtx-serial-win32-nar__V2.1.7-r2.jar
  #   org/concord/external/sound/jlayer/jlayer__V1.0.jar
  #   org/concord/external/sound/mp3spi/mp3spi__V1.9.4.jar
  #   org/concord/external/sound/tritonus/tritonus__V0.1.jar
  #   org/concord/external/vecmath/vecmath__V2.0.jar
  #   org/concord/framework/framework__V0.1.0-20080306.210010-141.jar
  #   org/concord/frameworkview/frameworkview__V0.1.0-20080305.205955-32.jar
  #   org/concord/ftdi-serial-wrapper/ftdi-serial-wrapper__V0.1.0-20071208.222126-20.jar
  #   org/concord/ftdi-serial-wrapper-native/ftdi-serial-wrapper-native-win32-nar__V0.1.0-20070303.181906-4.jar
  #   org/concord/graph/graph__V0.1.0-20071208.221811-45.jar
  #   org/concord/graphutil/graphutil__V0.1.0-20080206.170117-89.jar
  #   org/concord/httpclient/httpclient__V0.1.0-20071212.220020-17.jar
  #   org/concord/loader/loader__V0.1.0-20071207.234707-24.jar
  #   org/concord/math/math__V0.1.0-20071207.221359-24.jar
  #   org/concord/otrunk/data-util/data-util__V0.1.0-20080215.170056-146.jar
  #   org/concord/otrunk/otrunk-velocity/otrunk-velocity__V0.1.0-20071207.201957-21.jar
  #   org/concord/otrunk/otrunk__V0.1.0-20080305.205802-425.jar
  #   org/concord/otrunk-ui/otrunk-ui__V0.1.0-20080310.210028-132.jar
  #   org/concord/portfolio/portfolio__V0.1.0-20080303.230151-55.jar
  #   org/concord/sensor/labpro-usb/labpro-usb__V0.1.0-20071207.225156-8.jar
  #   org/concord/sensor/labpro-usb-native/labpro-usb-native-win32-nar__V0.1.0-20070606.192155-3.jar
  #   org/concord/sensor/sensor-dataharvest/sensor-dataharvest__V0.1.0-20070607.155431-8.jar
  #   org/concord/sensor/sensor-pasco/sensor-pasco__V0.1.0-20070405.151628-5.jar
  #   org/concord/sensor/sensor-vernier/sensor-vernier__V0.1.0-20080101.035208-31.jar
  #   org/concord/sensor/sensor__V0.1.0-20080229.053155-68.jar
  #   org/concord/sensor/ti/ti-cbl/ti-cbl-win32-nar__V0.1.1.jar
  #   org/concord/sensor/vernier/vernier-goio/vernier-goio-macosx-nar__V1.0.0.jar
  #   org/concord/sensor/vernier/vernier-goio/vernier-goio-win32-nar__V1.0.0.jar
  #   org/concord/sensor-native/sensor-native__V0.1.0-20080220.200100-39.jar
  #   org/concord/swing/swing__V0.1.0-20080303.163057-72.jar
  #   oro/oro/oro__V2.0.8.jar
  #   sslext/sslext/sslext__V1.2-0.jar
  #   velocity/velocity/velocity__V1.4.jar
  #   velocity/velocity-dep/velocity-dep__V1.4.jar"]
  #
  # Adding the option _:include_pack_gz => true_ will result in also copying
  # all the *.pack.gz versions of the resources to the local cache directory.
  #
  #   j = Jnlp::Jnlp.new("http://jnlp.concord.org/dev/org/concord/maven-jnlp/otrunk-sensor/otrunk-sensor.jnlp", 'web_start_cache', :include_pack_gz => true)
  #
  # Adding the option _:verbose => true_ will display a log of actions
  #
  # Note:
  #
  # The jnlp gem has a dependency on hpricot version 0.6.164.
  # The most recent version of hpricot, version 0.7.0 does not yet work with JRuby.
  # 
  class Jnlp
    #
    # Sets the Java Classpath delimiter used when generating 
    # a Classpath string
    CLASSPATH_DELIMETER = ':' unless defined? CLASSPATH_DELIMETER
    #
    # Contains a Hpricot XML doc of the original jnlp
    #
    attr_reader :jnlp
    #
    # Contains a Hpricot XML doc of the jnlp converted to reference the local cache
    #
    attr_reader :local_jnlp
    #
    # Contains the full path of the original jnlp
    #
    # Example:
    #
    #    "http://jnlp.concord.org/dev/org/concord/maven-jnlp/otrunk-sensor/otrunk-sensor.jnlp"
    #
    attr_reader :path
    #
    # Contains the name of the jnlp
    #
    # Example:
    #
    #    "otrunk-sensor.jnlp"
    #
    attr_reader :name
    #
    # Contains the local file-based href attribute of the 
    # local jnlp if it has been created.
    #
    # Example:
    #
    #    file:/Users/stephen/dev/otrunk-sensor/otrunk-sensor.jnlp"
    #
    attr_reader :local_jnlp_href
    #
    # Contains the local file-based name attribute of the 
    # of the local jnlp if it has been created.
    #
    # Example:
    #
    #    otrunk-sensor.jnlp"
    #
    attr_reader :local_jnlp_name
    # 
    # Contains the relative path to local cache directory if it has been set
    #
    # Example:
    #
    #   "cache"
    #
    attr_reader :relative_local_cache_dir
    # 
    # Contains the absolute path to the local cache directory if it has been set
    #
    # Example:
    #
    #   "/Users/stephen/dev/jetty-jnlp-proxy/cache"
    #
    attr_reader :local_cache_dir
    # 
    # Contains a boolean value indicating if the signatures of all
    # resources copied to local cache have been verified.
    #
    # The value is nil if no local cache has been created.
    #
    # Example:
    #
    #   true || false || nil
    #
    attr_accessor :local_resource_signatures_verified
    #
    # contans the boolean attribute determining whether 
    # gzipped pack200 resources should be copied to the 
    # local cache when the cache is updated
    #
    attr_accessor :include_pack_gzip
    #
    # Contains the spec attribute in the jnlp element 
    # Example: 
    #
    #   "1.0+"
    #
    attr_reader :spec
    #
    # Contains the codebase attribute in the jnlp element 
    # Example: 
    #
    #   "http://jnlp.concord.org/dev"
    #
    attr_reader :codebase
    #
    # Contains the href attribute in the jnlp element 
    # Example: 
    #
    #   "http://jnlp.concord.org/dev/org/concord/maven-jnlp/all-otrunk-snapshot/all-otrunk-snapshot.jnlp"
    #
    attr_reader :href
    #
    # Contains the value of the jnlp/information/title element
    # Example: 
    #
    #   "All OTrunk snapshot"
    #
    attr_reader :title
    #
    # Contains the value of the jnlp/information/vendor element
    # Example: 
    #
    #   "Concord Consortium"
    #
    attr_reader :vendor
    #
    # Contains the value of the href attribute in the jnlp/information/homepage element
    # Example: 
    #
    #   "http://www.concord.org"
    #
    attr_reader :homepage
    #
    # Contains the value of the jnlp/information/description element
    # Example: 
    #
    #   "http://www.concord.org"
    #
    attr_reader :description
    #
    # Contains a Jnlp::Icon object encapsulating the
    # jnlp/information/icon element if it exists in the 
    # original jnlp
    #
    attr_reader :icon
    #
    # Contains a boolean value indictating the presence of the 
    # jnlp/information/offline-allowed element
    #
    attr_reader :offline_allowed
    #
    # Contains an array of Jnlp::J2se objects encapsulating 
    # jnlp/resources/j2se elements
    #
    attr_reader :j2ses
    #
    # Contains an array of Jnlp::Property objects encapsulating 
    # jnlp/resources/property elements
    #
    attr_reader :properties
    #
    # Contains an array of Jnlp::Resource objects encapsulating 
    # jnlp/resources/jar elements
    #
    attr_reader :jars
    #
    # Contains an array of Jnlp::Resource objects encapsulating 
    # jnlp/resources/nativelib elements
    #
    attr_reader :nativelibs
    #
    # Contains the value of the main-class attribute in the jnlp/application-desc element
    # Example: "http://www.concord.org"
    #
    attr_reader :main_class
    #
    # Contains the value of the jnlp/application-desc/argument element
    # Example: "http://www.concord.org"
    #
    attr_reader :argument
    #    
    # Create a new Jnlp by loading and parsing the Java Web Start
    # Jnlp located at _path_ -- _path_ can be a local path or a url.
    # * if you include _cache_dir_ then the jnlp resources will be cached locally when the object is created
    # * If you also include a boolean true the pack_gzip versions of the resources will be cached also.
    #
    def initialize(path=nil, cache_dir=nil, options={})
      if cache_dir
        self.local_cache_dir=(cache_dir)
      end
      @include_pack_gzip = options[:include_pack_gzip]
      @verbose = options[:verbose]
      import_jnlp(path) unless path.empty?
    end
    
    def j2se_version(os=nil, arch=nil)
      j2se = j2ses.detect { |j2se| j2se.os == os && j2se.arch == arch}
      j2se ? j2se.version : nil
    end
    
    def max_heap_size(os=nil, arch=nil)
      j2se = j2ses.detect { |j2se| j2se.os == os && j2se.arch == arch }
      j2se ? j2se.max_heap_size : nil      
    end
    
    def initial_heap_size(os=nil, arch=nil)
      j2se = j2ses.detect { |j2se| j2se.os == os && j2se.arch == arch }
      j2se ? j2se.initial_heap_size : nil            
    end

    def java_vm_args(os=nil, arch=nil)
      j2se = j2ses.detect { |j2se| j2se.os == os && j2se.arch == arch }
      j2se ? j2se.java_vm_args : nil            
    end
    
    
    #
    # Saves a YAML version of the jnlp object.
    #
    # You can later recreate the object like this:
    #
    #   j = YAML.load(File.read("saved_jnlp_object"))
    #
    def save(filename="saved_jnlp_object")
      File.open(filename, 'w') {|f| f.write YAML.dump(self)}
    end    
    #
    # set
    #
    def local_cache_dir=(dir)
      @local_cache_dir = File.expand_path(dir)
      @relative_local_cache_dir = @local_cache_dir.split(File::SEPARATOR).last
    end
    #
    # Rebuild the Jnlp by loading and parsing the Java Web Start
    # Jnlp located at _path_ -- _path_ can be a local path or a url.
    #
    # If @local_cache_dir is set then the cache directory wll be updated also.
    #
    # If @include_pack_gzip is set then the gzipped pack200 versions of the resources
    # will be cached also.
    #
    def import_jnlp(path)
      @path = path
      @name = File.basename(@path)
      #
      # @local_jnlp_href and @local_jnlp_name are only placeholders
      # values so far-- they will become valid when a local jnlp file 
      # is written to the filesystem with this method:
      #
      #   Jnlp#write_local_jnlp
      # 
      @local_jnlp_name = "local-#{@name}"
      @local_jnlp_href = File.expand_path("#{Dir.pwd}/#{@local_jnlp_name}")    
      @jnlp = Hpricot.XML(open(path))
      @spec = (@jnlp/"jnlp").attr('spec')
      @codebase = (@jnlp/"jnlp").attr('codebase')
      @href = (@jnlp/"jnlp").attr('href')
      @title, @vendor, @homepage, @description, @icon = nil, nil, nil, nil, nil
      unless (info = (@jnlp/"information")).empty?
        @title = (info/"title").inner_html.strip
        @vendor = (info/"vendor").inner_html.strip
        @homepage = (info/"homepage").empty? ? '' : (info/"homepage").attr('href')
        @description = (info/"description").empty? ? '' : (info/"description").inner_html.strip
        icon = (info/"icon")
        @icon = Icon.new(icon) unless icon.empty?
        @offline_allowed = (info/"offline-allowed") ? true : false
      end
      @main_class = (@jnlp/"application-desc").attr('main-class')
      @argument = (@jnlp/"argument").inner_html.strip
      @j2ses, @properties, @jars, @nativelibs = [], [], [], []
      (@jnlp/"resources").each do |resources|
        if os = resources[:os]
          os = os.strip.downcase.gsub(/\W+/, '_').gsub(/^_+|_+$/, '')
        end
        if arch = resources[:arch]
          arch = arch.strip.downcase.gsub(/\W+/, '_').gsub(/^_+|_+$/, '')
        end
        (resources/"j2se").each { |j2se| @j2ses << J2se.new(j2se, os, arch) }
        (resources/"property").each { |prop| @properties << Property.new(prop, os) }
        (resources/"jar").each { |res| @jars << Resource.new(res, @codebase, os) }
        (resources/"nativelib").each { |res| @nativelibs << Resource.new(res, @codebase, os) }
      end
      if @local_cache_dir
        cache_resources(@local_cache_dir, @include_pack_gzip)
        generate_local_jnlp
      end
    end
    #
    # Copy all the jars and nativelib resources referenced in the Jnlp to
    # a local cache dir passed in _dest_dir_. The structure of the cache directory
    # and the naming using for the jar and nativelib files is the same as that used
    # by the Java Web Start Download Servlet, see: 
    # * http://java.sun.com/javase/6/docs/technotes/guides/javaws/developersguide/downloadservletguide.html
    #
    def cache_resources(dest_dir=@local_cache_dir, include_pack_gz = @include_pack_gzip)
      unless dest_dir
        raise ArgumentError, "Must specify destination directory when caching resources", caller
      end
      self.local_cache_dir=dest_dir
      @local_resource_signatures_verified = true
      @jars.each do |j|
        @local_resource_signatures_verified &&= j.cache_resource(dest_dir, include_pack_gz)
      end
      @nativelibs.each do |n|
        @local_resource_signatures_verified &&= n.cache_resource(dest_dir, include_pack_gz)
      end
      if @local_resource_signatures_verified
        generate_local_jnlp
      end
      @local_resource_signatures_verified = @local_resource_signatures_verified ? true : false
    end
    #
    # Copies the original Hpricot jnlp into @local_jnlp
    # and modified it to use the local cache.
    #
    def generate_local_jnlp
      #
      # get a copy of the existing jnlp 
      # (it should be easier than this)
      #
      @local_jnlp = Hpricot.XML(@jnlp.to_s)
      #
      # we'll be working with the Hpricot root element
      #
      jnlp_elem = (@local_jnlp/"jnlp").first
      #
      # set the new codebase
      #
      jnlp_elem[:codebase] = "file:#{@local_cache_dir}"
      #      
      # set the new href
      #
      jnlp_elem[:href] = @local_jnlp_href
      #
      # for each jar and nativelib remove the version
      # attribute and point the href to he local ache
      #
      @jars.each do |jar|
        j = @local_jnlp.at("//jar[@href=#{jar.href}]")
        j.remove_attribute(:version)
        j[:href] = jar.relative_local_path
      end
      @nativelibs.each do |nativelib|
        nl = @local_jnlp.at("//nativelib[@href=#{nativelib.href}]")
        nl.remove_attribute(:version)
        nl[:href] = nativelib.relative_local_path
      end
    end
    #
    # Returns an array containing all the local paths for this jnlp's resources.
    #
    # Pass in the optional hash: (:remove_jruby => true) and
    # the first resource that contains the string /jruby/ will 
    # be removed from the returned array.
    #
    # Example:
    #
    #   resource_paths(:remove_jruby => true)
    #
    # This is useful when the jruby-complete jar has been included 
    # in the jnlp and you don't want to require that jruby into this
    # specific instance which is already running jruby.
    #
    # Here's an example of a jruby resource reference:
    #
    #    "org/jruby/jruby/jruby__V1.0RC2.jar"
    #
    def resource_paths(options={})
      cp_jars = @jars.collect {|j| j.local_path}
      cp_nativelibs = @nativelibs.collect {|n| n.local_path}
      resources = cp_jars + cp_nativelibs
      #
      # FIXME: this should probably be more discriminatory 
      #
      if options[:remove_jruby]
        resources = resources.reject {|r| r =~ /\/jruby\//}
      end
      resources
    end
    #
    # Returns a string in Java classpath format for all the jars for this jnlp
    # The delimiter used is the ':' which is valid for MacOS X and Linux. 
    # Windows uses the ';' as a delimeter.
    #
    # Pass in the optional hash: (:remove_jruby => true) and
    # the first resource that contains the string /jruby/ will 
    # be removed from the returned classapath string.
    #
    # Example:
    #
    #   local_classpath(:remove_jruby => true)
    #
    def local_classpath(options={})
      resource_paths(options).join(CLASSPATH_DELIMETER)
    end
    #
    # Writes a shell script to the local filesystem
    # that will export a modified CLASSPATH environmental 
    # variable with the paths to the resources used by
    # this jnlp.
    #
    # Writes a jnlp to current working directory 
    # using name of original jnlp.
    #   
    # Pass in the optional hash: (:remove_jruby => true) and
    # the first resource that contains the string /jruby/ will 
    # be removed from the classapath shell script.
    #
    # Example:
    #
    #   write_local_classpath_shell_scrip(:remove_jruby => true)
    #
    def write_local_classpath_shell_script(filename="#{@name[/[A-Za-z0-9_-]*/]}_classpath.sh", options={})
      script = "export CLASSPATH=$CLASSPATH#{local_classpath(options)}"
      File.open(filename, 'w'){|f| f.write script}
    end
    #
    # returns the jnlp as a string
    #
    def to_jnlp
      @jnlp.to_s
    end
    #
    # returns the local file-based jnlp as a string
    #    
    def to_local_jnlp
      @local_jnlp.to_s
    end
    #
    # Writes a local copy of the original jnlp .
    #
    # Writes jnlp to current working directory 
    # using name of original jnlp.
    #   
    def write_jnlp(filename=@name)
      File.open(filename, 'w') {|f| f.write to_jnlp }
    end
    #
    # Writes a local file-based jnlp.
    #
    # Will write jnlp to current working directory 
    # using name of original jnlp with "local-" prefix.
    #   
    def write_local_jnlp(filename=@local_jnlp_name)
      destination = File.expand_path(filename)
      unless @local_jnlp_href == destination
        @local_jnlp_href = destination
        @local_jnlp_name = File.basename(destination)
        self.generate_local_jnlp
      end
      File.open(filename, 'w') {|f| f.write to_local_jnlp }
    end
    #
    # This will add all the jars for this jnlp to the effective
    # classpath for this Java process.
    # 
    # *If* you are already running in JRuby *AND* the jnlp references a 
    # JRuby resource the JRuby resource will not be required.
    #
    def require_resources
      if RUBY_PLATFORM =~ /java/
        resource_paths(:remove_jruby => true).each {|res| require res}
        true
      else
        false
      end
    end
    #
    # This will start the jnlp as a local process.
    #
    # This only works in MRI at this point.
    #
    def run_local(argument=@argument)
      if RUBY_PLATFORM =~ /java/
        puts "not implemented in JRuby yet"
      else
        command = "java -classpath #{local_classpath} #{@main_class} '#{@argument}'"
        $pid = fork { exec command }
      end
    end
    #
    # This will stop the running local process,
    # started by Jnlp#run_local.
    #
    # This only works in MRI at this point.
    #
    def stop_local
      if RUBY_PLATFORM =~ /java/
        puts "not implemented in JRuby yet"
      else
        Process.kill 15, $pid
        Process.wait($pid)
      end
    end
  end
end

