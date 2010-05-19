require 'open-uri'
require 'hpricot'

module Jnlp #:nodoc:
  # 
  #
  require "jnlp.rb"
  
  # == VersionedJnlpUrl
  #
  # Encapsulates a versioned jnlp in a Maven Jnlp Web Start server.
  #
  #   Jnlp::VersionedJnlpUrl.new(family_name, path, base_url)
  #
  # Example:
  #
  #   require 'jnlp'
  #   vju = Jnlp::VersionedJnlpUrl("concord", "/dev/org/concord/maven-jnlp/", "http://jnlp.concord.org")
  #
  # Example:
  #
  #   vju = Jnlp::VersionedJnlpUrl("concord", "/dev/org/concord/maven-jnlp/", "http://jnlp.concord.org")
  #
  class VersionedJnlpUrl
    #
    # Contains the the full path to the jnlp
    #
    #   "/dev/org/concord/maven-jnlp/all-otrunk-snapshot/all-otrunk-snapshot-0.1.0-20070420.131610.jnlp"
    #
    attr_reader :path
    #
    # Contains the the full url to the jnlp
    #
    #   "http://jnlp.concord.org/dev/org/concord/maven-jnlp/all-otrunk-snapshot/all-otrunk-snapshot-0.1.0-20090327.222627.jnlp"
    #
    attr_reader :url
    #
    #
    # Contains the maven-jnlp version string for the jnlp 
    #
    #   "0.1.0-20090327.222627"
    #
    attr_reader :version
    #
    # Pass in:
    #
    #    family_name, path, base_url
    #    
    def initialize(family_name, path, base_url)
      @path = path
      @url = base_url + @path
      @version = @url[/#{family_name}\/#{family_name}-(.*)\.jnlp/, 1]
    end
  end

  # == MavenJnlpFamily
  #
  # Encapsulates a single MavenJnlp Family of versioned jnlps.
  #
  #   Jnlp::MavenJnlpFamily.new(base_url, family_path)
  #
  # Example:
  #
  #   require 'jnlp'
  #   mjf = Jnlp::MavenJnlpFamily.new('http://jnlp.concord.org', '/dev/org/concord/maven-jnlp/all-otrunk-snapshot')
  #
  #   mjf = Jnlp::MavenJnlpFamily.new('http://jnlp.concord.org', '/dev/org/concord/maven-jnlp/all-otrunk-snapshot', 
  #     { :versions => ['0.1.0-20100513.161426', '0.1.0-20100513.154925'] })
  # You can pass in an options hash to limit the number of versioned jnlps parsed:
  #
  # Example
  #
  #   mjf = Jnlp::MavenJnlpFamily.new('http://jnlp.concord.org', '/dev/org/concord/maven-jnlp/all-otrunk-snapshot', 
  #        { :versions => ['0.1.0-20100513.161426', '0.1.0-20100513.154925'] })
  #
  #   mjf.versions.length
  #   => 2
  #
  class MavenJnlpFamily
    #
    # Contains the base_url for this MavenJnlp server
    #
    # Example:
    #
    #   "http://jnlp.concord.org"
    #
    attr_reader :base_url
    #
    # Contains the path from the base_url to the root for 
    # this family of jnlps 
    #
    # Example:
    #
    #   "/dev/org/concord/maven-jnlp/"
    #
    attr_reader :path
    #
    # Contains the root url for this family of jnlps 
    #
    # Example:
    #
    #   "http://jnlp.concord.org/dev/org/concord/maven-jnlp/all-otrunk-snapshot"
    #
    attr_reader :url
    #
    # Contains the name for this family of jnlps 
    #
    # Example:
    #
    #   "all-otrunk-snapshot"
    #
    attr_reader :name
    #
    # Contains an array of VersionedJnlpUrls 
    #
    attr_reader :versions
    #
    # Contains the version string for the latest versioned jnlp.
    # This jnlp this version string refers to is identical to 
    # the snapshot jnlp at the of processing.
    #
    # Example:
    #
    #   "0.1.0-20090327.222627"
    #
    attr_reader :snapshot_version
    #
    # Contains the VersionedJnlpUrl referencing the latest 
    # versioned jnlp. This jnlp is identical to the snapshot 
    # jnlp at the time of instantiation. 
    #
    attr_reader :snapshot
    #
    # Pass in:
    #
    #    base_url, family_path
    #
    
    def initialize(base_url, family_path, options={})
      @base_url = base_url
      @path = family_path
      @url = @base_url + @path
      @name = File.basename(@path)
      @versions = []
      doc = Hpricot(open(@url))
      anchor_tags = doc.search("//a")
      snapshot_version_path = anchor_tags.find {|a| a['href'][/CURRENT_VERSION\.txt$/] }['href']
      @snapshot_version = open(base_url + snapshot_version_path).read
      jnlp_paths = anchor_tags.find_all { |a| a['href'][/jnlp$/] }.collect { |a| a['href'] }
      jnlp_paths.each do |jnlp_path|
        version = jnlp_path[/#{name}\/#{name}-(.*)\.jnlp/, 1]
        # skip processing unless this jnlp has a version string
        if version
          # only continue processing if:
          #   no options[:version] was passed in OR
          #   the current version matches one of the desired versions OR
          #   one of the desired versions is 'snapshot' and this version IS the snapshot version
          if  options[:versions] == nil || 
              options[:versions].any? { |v| v == version } ||
              options[:versions].any? { |v| v == 'snapshot' && version == @snapshot_version } 
            versioned_jnlp_url = VersionedJnlpUrl.new(@name, jnlp_path, @base_url)
            @versions << versioned_jnlp_url
            if versioned_jnlp_url.version == @snapshot_version
              @snapshot = versioned_jnlp_url
            end
          end
        end
      end
    end
    
    def update
      
    end
    
    def latest_snapshot_version
      open("#{@url}/#{@name}-CURRENT_VERSION.txt").read
    end
  end

  # == MavenJnlp
  #
  # Given the url to the root of an active MavenJnlp web start servlet 
  # a new instance of MavenJnlp will find all the families, all the
  # versions for each family, and determine the current version.
  #
  # Example:
  #
  #   require 'jnlp'
  #   mj = Jnlp::MavenJnlp.new('http://jnlp.concord.org', '/dev/org/concord/maven-jnlp/')
  #
  # This takes about 90s on a 3Mbps connection processing Concord's
  # Maven Jnlp Web Start server.
  #
  # You can now do this:
  #
  #   mj.maven_jnlp_families.length                        # => 26
  #   mj.maven_jnlp_families[0].name                       # => "all-otrunk-snapshot"
  #   mj.maven_jnlp_families[0].versions.length            # => 1568
  #   mj.maven_jnlp_families[0].versions.first.version     # => "0.1.0-20070420.131610"
  #   mj.maven_jnlp_families[0].snapshot_version           # => "0.1.0-20090327.222627"
  #
  #   mj.maven_jnlp_families[0].versions.last.url
  #
  #   # => "/dev/org/concord/maven-jnlp/all-otrunk-snapshot/all-otrunk-snapshot-0.1.0-20090327.222627.jnlp"
  #  
  #   mj.maven_jnlp_families[0].snapshot.url
  #
  #   # => "/dev/org/concord/maven-jnlp/all-otrunk-snapshot/all-otrunk-snapshot-0.1.0-20090327.222627.jnlp"
  #
  #   mj.maven_jnlp_families[0].versions.first.url
  #
  #   # => "/dev/org/concord/maven-jnlp/all-otrunk-snapshot/all-otrunk-snapshot-0.1.0-20070420.131610.jnlp"
  #
  # You can pass in an options hash to limit the number of maven jnlp families parsed:
  #
  # Example: passing in an optional array of maven jnlp families
  # This will get all versions of each family.
  #
  #   mj = Jnlp::MavenJnlp.new('http://jnlp.concord.org', '/dev/org/concord/maven-jnlp/', 
  #        { :families => ['all-otrunk-snapshot', 'gui-testing'] })
  #
  #   mj.maven_jnlp_families.length
  #   => 2
  #
  # Example: passing in an optional hash of maven jnlp families
  # This will get all versions of each family.
  #
  #   mj = Jnlp::MavenJnlp.new('http://jnlp.concord.org', '/dev/org/concord/maven-jnlp/', 
  #        { :families => { 'all-otrunk-snapshot' => nil, 'gui-testing' => nil } })
  #
  #   mj.maven_jnlp_families.length
  #   => 2
  #
  # Example: passing in an optional hash of maven jnlp families and specifying
  # the versions of the jnlp urls to get for one family.
  #
  #   mj = Jnlp::MavenJnlp.new('http://jnlp.concord.org', '/dev/org/concord/maven-jnlp/',
  #        { :families => { 
  #          'all-otrunk-snapshot' => { :versions => ['0.1.0-20100513.161426', '0.1.0-20100513.154925'] },
  #          'gui-testing' => nil }
  #        })
  #   mjfs = mj.maven_jnlp_families
  #   [mjfs.length, mjfs[0].versions.length, mjfs[1].versions.length]
  #   => [2, 2, 50]
  #
  class MavenJnlp
    #
    # Contains the base_url for this MavenJnlp server
    #
    # Example:
    #
    #   'http://jnlp.concord.org'
    #
    attr_reader :base_url
    #
    # Contains the path to the jnlp families for 
    # this MavenJnlp server
    #
    # Example:
    #
    #   '/dev/org/concord/maven-jnlp/'
    #
    attr_reader :jnlp_families_path
    #
    # Contains the url to the jnlp families for 
    # this MavenJnlp server
    #
    # Example:
    #
    #   'http://jnlp.concord.org/dev/org/concord/maven-jnlp/'
    #
    attr_reader :jnlp_families_url
    #
    # Contains an array of MavenJnlpFamilies 
    #
    attr_reader :maven_jnlp_families
    #
    # Pass in:
    #
    #    base_url, maven_jnlp_path
    #
    def initialize(base_url, jnlp_families_path, options={})
      @base_url = base_url
      @jnlp_families_path = jnlp_families_path
      @jnlp_families_url = @base_url + @jnlp_families_path
      @maven_jnlp_families = []
      doc = Hpricot(open(@jnlp_families_url))
      family_paths = doc.search("//a").find_all { |a| 
        a['href'][/#{@jnlp_families_path}/] 
      }.collect { |a| a['href'] }
      if options[:families]
        case options[:families]
        when Hash
          options[:families].each do |family, versions|
            family_path = family_paths.detect { |fp| family == File.basename(fp) }
            if family_path
              maven_jnlp_family = MavenJnlpFamily.new(@base_url, family_path, versions || {}) 
              @maven_jnlp_families << maven_jnlp_family
            end
          end
        when Array
          family_paths = family_paths.select { |path| 
            options[:families].any? { |family| family == File.basename(path) }
          }
          family_paths.each do |family_path|
            maven_jnlp_family = MavenJnlpFamily.new(@base_url, family_path) 
            @maven_jnlp_families << maven_jnlp_family
          end
        end
      end
    end
    
    #
    # summarize
    #
    # Display a summary of the jnlp families and versions 
    # available on stdout.
    #
    # Example:
    #
    #   require 'jnlp'
    #   mj = Jnlp::MavenJnlp.new('http://jnlp.concord.org', '/dev/org/concord/maven-jnlp/')
    #   mj.summarize                 
    #   
    #   Maven Jnlp families: 26
    #   
    #   name: all-otrunk-snapshot
    #     versions: 1568
    #     current snapshot version: 0.1.0-20090327.222627
    #   
    #   name: all-otrunk-snapshot-with-installer
    #     versions: 167
    #     current snapshot version: 0.1.0-20090327.222727
    #   
    #   name: capa-measuring-resistance
    #     versions: 1496
    #     current snapshot version: 0.1.0-20090327.222729
    #   
    #   name: capa-otrunk
    #     versions: 1172
    #     current snapshot version: 0.1.0-20090327.222733
    #
    #   ...
    #
    def summarize
      puts 
      puts "Maven Jnlp families: #{@maven_jnlp_families.length}"
      puts
      @maven_jnlp_families.each do |family|
        puts "name: #{family.name}"
        puts "  versions: #{family.versions.length}"
        puts "  current snapshot version: #{family.snapshot_version}"
        puts
      end
      puts
    end

  end
end
