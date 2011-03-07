config_headers(runnable)
session_options = request.env["rack.session.options"]
xml.java(:class => "java.beans.XMLDecoder", :version => "1.4.0") {
  xml.object("class" => "net.sf.sail.emf.launch.HttpCookieServiceImpl") {
    xml.void("property" => "cookieProperties") {
      xml.object("class" => "java.util.Properties") {
        xml.void("method" => "setProperty") {
          xml.string("*.concord.org")
          xml.string("#{session_options[:key]}=#{session_id}; path=#{session_options[:path]}")
        }
      }
    }
  }
  xml.object(:class => "net.sf.sail.emf.launch.ConsoleLogServiceImpl") { 
  }
  xml.object(:class => "org.telscenter.sailotrunk.OtmlUrlCurnitProvider") { 
    xml.void(:property => "viewSystem") { 
      xml.boolean "true"
    }
  }
  xml.object(:class => "net.sf.sail.emf.launch.PortfolioManagerService") { 
    xml.void(:property => "portfolioUrlProvider") { 
      xml.object(:class => "net.sf.sail.emf.launch.XmlUrlStringProviderImpl") { 
        xml.void(:property => "urlString") { 
          xml.string root_path(:only_path => false) + 'bundles/empty_bundle.xml'
        }
      }
    }
  }
  xml.object(:class => "net.sf.sail.core.service.impl.LauncherServiceImpl") { 
    xml.void(:property => "properties") { 
      xml.object(:class => "java.util.Properties") { 
        xml.void(:method => "setProperty") { 
          xml.string "sds_time"
          xml.string((Time.now.to_f * 1000).to_i)
        }
        xml.void(:method => "setProperty") { 
          xml.string "sailotrunk.hidetree"
          xml.string "false"
        }
        xml.void(:method => "setProperty") { 
          xml.string "sailotrunk.otmlurl"
          if teacher_mode && runnable.class == Investigation 
            xml.string investigation_teacher_dynamic_otml_url(runnable)
          else
            xml.string polymorphic_url(runnable, :format => :dynamic_otml, :teacher_mode => false, :action => :edit)
          end
        }
      }
    }
  }
  xml.object :class => "net.sf.sail.emf.launch.EMFSailDataStoreService2"
  xml.object(:class => "net.sf.sail.core.service.impl.UserServiceImpl") { 
    xml.void(:property => "participants") { 
    }
    xml.void(:property => "userLookupService") { 
      xml.object :class => "net.sf.sail.core.service.impl.UserLookupServiceImpl"
    }
  }
  xml.object :class => "net.sf.sail.core.service.impl.SessionLoadMonitor"
  xml.object :class => "net.sf.sail.core.service.impl.SessionManagerImpl"
}
