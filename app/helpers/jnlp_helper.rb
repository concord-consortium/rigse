module JnlpHelper

  def resource_jars
    [
      ['org/telscenter/sail-otrunk/sail-otrunk.jar', '0.1.0-20090503.234506-977'],
      ['org/concord/otrunk/otrunk.jar', '0.1.0-20090505.170205-873'],
      ['org/concord/framework/framework.jar', '0.1.0-20090505.040008-330'],
      ['org/concord/frameworkview/frameworkview.jar', '0.1.0-20090506.160012-146'],
      ['org/concord/swing/swing.jar', '0.1.0-20090506.154011-176'],
      ['jug/jug/jug.jar', '1.1.2'],
      ['jdom/jdom/jdom.jar', '1.0'],
      ['org/concord/apple-support/apple-support.jar', '0.1.0-20090413.174434-118'],
      ['org/concord/loader/loader.jar', '0.1.0-20090427.180055-113'],
      ['net/sf/sail/sail-core/sail-core.jar', '0.4.5-20090506.065313-1143'],
      ['commons-beanutils/commons-beanutils/commons-beanutils.jar', '1.7.0'],
      ['commons-logging/commons-logging/commons-logging.jar', '1.0.4'],
      ['commons-lang/commons-lang/commons-lang.jar', '2.0'],
      ['commons-io/commons-io/commons-io.jar', '1.1'],
      ['log4j/log4j/log4j.jar', '1.2.8'],
      ['rhino/js/js.jar', '1.5R4.1'],
      ['script/jsr223/jsr223.jar', '1.0'],
      ['xstream/xstream/xstream.jar', '1.1.2'],
      ['net/sf/sail/sail-data-emf/sail-data-emf.jar', '0.1.0-20090506.165007-1170', 'main => "true'],
      ['org/eclipse/emf/ecore/ecore.jar', '2.2.0'],
      ['org/eclipse/emf/common/common.jar', '2.2.0'],
      ['org/eclipse/emf/ecore-xmi/ecore-xmi.jar', '2.2.0'],
      ['org/concord/portfolio/portfolio.jar', '0.1.0-20090506.170118-312'],
      ['org/concord/otrunk-ui/otrunk-ui.jar', '0.1.0-20090506.170031-556'],
      ['org/concord/external/sound/jlayer/jlayer.jar', '1.0'],
      ['org/concord/external/sound/mp3spi/mp3spi.jar', '1.9.4'],
      ['org/concord/external/sound/tritonus/tritonus.jar', '0.1'],
      ['org/concord/external/ekit/ekit.jar', '1.0'],
      ['org/concord/httpclient/httpclient.jar', '0.1.0-20080330.082248-19'],
      ['org/concord/datagraph/datagraph.jar', '0.1.0-20090506.160406-331'],
      ['org/concord/data/data.jar', '0.2.0-20090506.161358-14'],
      ['org/concord/graphutil/graphutil.jar', '0.1.0-20090506.160332-273'],
      ['org/concord/graph/graph.jar', '0.1.0-20090422.230008-140'],
      ['org/concord/pedagogica/pedagogica.jar', '0.1.0-20090506.162100-161'],
      ['org/concord/collisions/collisions.jar', '0.1.0-20090506.170324-327'],
      ['org/concord/math/math.jar', '0.1.0-20090413.174929-114'],
      ['org/concord/external/jep/jep.jar', '1.0'],
      ['org/concord/external/vecmath/vecmath.jar', '2.0'],
      ['org/concord/multimedia/multimedia.jar', '0.1.0-20090506.170239-338'],
      ['org/concord/external/animating-card-layout/animating-card-layout.jar', '1.0'],
      ['org/concord/otrunk/data-util/data-util.jar', '0.1.0-20090506.170201-547'],
      ['org/concord/sensor/sensor.jar', '0.1.0-20090505.040948-196'],
      ['org/concord/external/rxtx/rxtx-comm/rxtx-comm.jar', '2.1.7-r2'],
      ['org/concord/biologica/biologica.jar', '0.1.0-20090506.154503-403'],
      ['org/concord/external/jna/jna-examples/jna-examples.jar', '0.1.0-20090409.210850-1'],
      ['org/concord/external/jri/libjri/libjri.jar', '0.4-1-20081104.174358-4'],
      ['bsf/bsf/bsf.jar', '2.4.0'],
      ['org/concord/external/jna/jna-jws/jna-jws.jar', '3.0.9'],
      ['org/concord/otrunk-biologica/otrunk-biologica.jar', '0.1.0-20090506.170856-325'],
      ['org/concord/otrunk-mw/otrunk-mw.jar', '0.1.0-20090506.171047-557'],
      ['org/concord/modeler/mw/mw.jar', '2.1.0-20090506.161457-8'],
      ['org/concord/rtt-applets/rtt-applets.jar', '0.1.0-20090506.162219-164'],
      ['org/concord/graph-function/graph-function.jar', '0.1.0-20090505.040051-167'],
      ['org/concord/algebra-objects/algebra-objects.jar', '0.1.0-20090505.040145-189'],
      ['org/concord/shape-scaler/shape-scaler.jar', '0.1.0-20090506.162142-114'],
      ['org/concord/otrunk-nlogo4/otrunk-nlogo4.jar', '0.1.0-20090505.042728-159'],
      ['org/concord/nlogo/netlogo4lite/netlogo4lite.jar', '4.0-20080411.140821-1'],
      ['org/concord/external/log/log4j/log4j.jar', '1.2.15'],
      ['org/concord/otrunk/otrunk-phet/otrunk-phet.jar', '0.1.0-20090505.042836-180'],
      ['org/concord/external/phet/phetballoons/phetballoons.jar', '1.0.3'],
      ['org/concord/external/phet/phetramp/phetramp.jar', '1.0.0'],
      ['org/concord/external/phet/phetsound/phetsound.jar', '1.0.1'],
      ['org/concord/external/phet/phetdischargelamps/phetdischargelamps.jar', '1.0.1'],
      ['org/concord/external/phet/phetfaraday/phetfaraday.jar', '1.0.3'],
      ['org/concord/external/phet/phetwave/phetwave.jar', '1.0.3'],
      ['org/concord/external/phet/phetskatepark/phetskatepark.jar', '1.2'],
      ['org/concord/otrunk-cck/otrunk-cck.jar', '0.1.0-20090505.170433-354'],
      ['org/concord/external/phet/phetcck/phetcck.jar', '1.0.4-20090122.200346-31'],
      ['org/concord/examples/examples.jar', '0.1.0-20090506.170410-228'],
      ['org/concord/function-graph/function-graph.jar', '0.1.0-20090422.230550-96'],
      ['org/concord/otrunk/ot-script/ot-script-api/ot-script-api.jar', '0.1.0-20090505.170721-271'],
      ['org/concord/otrunk/otrunk-velocity/otrunk-velocity.jar', '0.1.0-20090505.170844-257'],
      ['org/apache/velocity/velocity/velocity.jar', '1.5'],
      ['commons-collections/commons-collections/commons-collections.jar', '3.1'],
      ['oro/oro/oro.jar', '2.0.8'],
      ['org/apache/velocity/velocity-tools/velocity-tools.jar', '1.3'],
      ['commons-digester/commons-digester/commons-digester.jar', '1.8'],
      ['commons-validator/commons-validator/commons-validator.jar', '1.3.1'],
      ['sslext/sslext/sslext.jar', '1.2-0'],
      ['velocity/velocity/velocity.jar', '1.4'],
      ['velocity/velocity-dep/velocity-dep.jar', '1.4'],
      ['org/concord/otrunk/otrunk-udl/otrunk-udl.jar', '0.1.0-20090506.171204-931'],
      ['org/concord/otrunk-browser/otrunk-browser.jar', '0.1.0-20090506.170456-324'],
      ['org/mozdev/mozswing/mozswing-complete/mozswing-complete.jar', '1.1'],
      ['org/concord/otrunk/ot-script/ot-javascript/ot-javascript.jar', '0.1.0-20090505.170952-274'],
      ['org/concord/external/tts/narrator/narrator.jar', '1.1'],
      ['org/concord/external/tts/freetts/freetts.jar', '1.1'],
      ['org/concord/external/tts/en_us/en_us.jar', '1.1'],
      ['org/concord/external/tts/cmutimelex/cmutimelexml.jar', '1.1'],
      ['org/concord/external/tts/cmulex/cmulexml.jar', '1.1'],
      ['org/concord/external/tts/cmudict04/cmudict04.jar', '1.1'],
      ['org/concord/external/tts/cmu_us_kal/cmu_us_kal.jar', '1.1'],
      ['org/concord/external/tts/cmu_time_awb/cmu_time_awb.jar', '1.1'],
      ['org/concord/otrunk/otrunk-swingx/otrunk-swingxml.jar', '0.1.0-20090506.171126-79'],
      ['org/swinglabs/swingx/swingxml.jar', '0.9.5-2'],
      ['org/concord/otrunk/otrunk-diy/otrunk-diy.jar', '0.1.0-20080326.093552-20'],
      ['org/concord/sensor-native/sensor-native.jar', '0.1.0-20090505.043216-187'],
      ['org/concord/sensor/sensor-vernier/sensor-vernier.jar', '0.1.0-20090502.033056-175'],
      ['org/concord/sensor/labpro-usb/labpro-usb.jar', '0.2.0-20090413.180004-3'],
      ['org/concord/sensor/labquest-jna/labquest-jna.jar', '0.1.0-20090413.180030-10'],
      ['org/concord/sensor/sensor-dataharvest/sensor-dataharvest.jar', '0.1.0-20090319.210620-9'],
      ['org/concord/ftdi-serial-wrapper/ftdi-serial-wrapper.jar', '0.1.0-20090427.180938-120'],
      ['org/concord/otrunk/ot-script/ot-bsf/ot-bsf.jar', '0.1.0-20090505.170921-275'],
      ['org/concord/otrunk/ot-script/ot-script-view/ot-script-view.jar', '0.1.0-20090505.171026-235'],
      ['org/concord/otrunk/ot-script/ot-jruby/ot-jruby.jar', '0.1.0-20090505.171448-263'],
      ['org/jruby/jruby-complete/jruby-complete.jar', '1.1.4'],
      ['org/concord/otrunk/ot-script/ot-jython/ot-jython.jar', '0.1.0-20090505.171526-254'],
      ['org/jython/jython/jython.jar', '2.2.1-20080311.150247-1'],
      ['org/concord/otrunk-collisions/otrunk-collisions.jar', '0.1.0-20090506.170943-304'],
      ['org/concord/otrunk/otrunk-intrasession/otrunk-intrasession.jar', '0.1.0-20090506.171014-165'],
      ['org/concord/otrunk/otrunk-report-libraries/otrunk-report-libraries.jar', '0.1.0-20090501.202753-3']
    ]
  end

  def linux_native_jars
    [
      ['org/concord/external/rxtx/rxtx-serial/rxtx-serial-linux-nar.jar', '2.1.7-r2']
    ]
  end
  
  def macos_native_jars
    [
      ['org/concord/external/rxtx/rxtx-serial/rxtx-serial-linux-nar.jar', '2.1.7-r2'],
      ['org/concord/external/jna/jna-jnidispatch/jna-jnidispatch-win32-nar.jar', '3.0.9'],
      ['org/concord/external/tts/quadmore/quadmore-win32-nar.jar', '1.0-20080128.214245-1'],
      ['org/concord/sensor/vernier/vernier-goio/vernier-goio-win32-nar.jar', '1.4.0'],
      ['org/concord/sensor/labpro-usb-native/labpro-usb-native-win32-nar.jar', '0.2.0-20090323.155823-1'],
      ['org/concord/ftdi-serial-wrapper-native/ftdi-serial-wrapper-native-win32-nar.jar', '0.1.0-20070303.181906-4'],
      ['org/concord/external/rxtx/rxtx-serial/rxtx-serial-win32-nar.jar', '2.1.7-r2'],
      ['org/concord/sensor/ti/ti-cbl/ti-cbl-win32-nar.jar', '0.1.1']
    ]
  end
  
  def windows_native_jars
    [
      ['org/concord/external/jri/libjri-native-osx/libjri-native-osx-macosx-nar.jar', '0.4-1-20081104.174859-5'],
      ['org/concord/external/jna/jna-jnidispatch/jna-jnidispatch-macosx-nar.jar', '3.0.9'],
      ['org/mozdev/mozswing/mozswing-cocoautils/mozswing-cocoautils-macosx-nar.jar', '1.0-20080124.063453-1'],
      ['org/concord/sensor/vernier/vernier-goio/vernier-goio-macosx-nar.jar', '1.4.0'],
      ['org/concord/external/rxtx/rxtx-serial/rxtx-serial-macosx-nar.jar', '2.1.7-r2']
    ]
  end
  
  def jnlp_resources(xml)
    xml.resources {
      xml.j2se :version => "1.5+", 'max-heap-size' => "128m", 'initial-heap-size' => "32m"
      resource_jars.each do |resource|
        xml.jar :version => resource[1], :href => resource[0]
      end
    }
  end

  def jnlp_resources_linux(xml)
    xml.resources(:os => "Linux") { 
      linux_native_jars.each do |resource|
        xml.nativelib :version => resource[1], :href => resource[0]
      end
    }
  end

  def jnlp_resources_macosx(xml)
    xml.resources(:os => "Mac OS X") { 
      macos_native_jars.each do |resource|
        xml.nativelib :version => resource[1], :href => resource[0]
      end
    }
  end

  def jnlp_resources_windows(xml)
    xml.resources(:os => "Windows") { 
      windows_native_jars.each do |resource|
        xml.nativelib :version => resource[1], :href => resource[0]
      end
    }
  end

end