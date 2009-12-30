== jnlp

A gem for encapsulating the content and resources referenced by Java Web Start jnlps

Complete rdoc available here: http://rubywebstart.rubyforge.org/jnlp/Jnlp/Jnlp.html

For more information about the structure of Java Web Start see:

http://java.sun.com/javase/6/docs/technotes/guides/javaws/developersguide/contents.html

To create a new Jnlp call Jnlp#new with a string that contains either a local path or a url.

Examples:

Creating a new Jnlp object from a local Java Web Start jnlp file. 

j = Jnlp::Jnlp.new("authoring.jnlp")

Creating a new Jnlp object from a Java Web Start jnlp referenced with a url. 

j = Jnlp::Jnlp.new("jnlp.concord.org/dev/org/concord/maven-jnlp/otrunk-sensor/otrunk-sensor.jnlp")

Once the Jnlp object is created you can call Jnlp#cache_resources to create a local cache of all the jar and nativelib resources. 

The structure of the cache directory and the naming using for the jar and nativelib files is the same as that used by the Java Web Start Download Servlet, see:

http://java.sun.com/javase/6/docs/technotes/guides/javaws/developersguide/downloadservletguide.html

== Building the gem

=== First patch Hoe

Hoe versions 1.11.0 and 1.11.1 do not work with JRuby.

To build the gem you will need to apply this patch to Hoe:
0001-install_gem-nows-works-with-jruby-also.patch[http://gist.github.com/raw/87670/7bd12ecff3e27dd0a1a1d750b61d4efece372374/0001-install_gem-nows-works-with-jruby-also.patch]

=== The source code

The source code for the jnlp gem is on github[http://github.com/stepheneb/jnlp/tree/master].

  git clone git://github.com/stepheneb/jnlp.git

