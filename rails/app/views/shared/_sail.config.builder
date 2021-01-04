all_properties = {
  'sds_time' => (Time.now.to_f * 1000).to_i,
  'sailotrunk.otmlurl' => otml_url
}
if local_assigns[:properties]
  all_properties.merge!(properties)
end

response.headers["Content-Type"] = "application/xml"
NoCache.add_headers(response.headers)
session_options = request.env["rack.session.options"]
xml.java(:class => "java.beans.XMLDecoder", :version => "1.4.0") {
  xml.object("class" => "net.sf.sail.emf.launch.HttpCookieServiceImpl") {
    xml.void("property" => "cookieProperties") {
      xml.object("class" => "java.util.Properties") {
        xml.void("method" => "setProperty") {
          # set cookie domain; seems to work for localhost and 127.0.0.1 too.
          xml.string(request.host.split(".")[1..-1].insert(0,"*").join("."))
          xml.string("#{Rails.application.config.session_options[:key]}=#{session_options[:id]}; path=#{session_options[:path]}")
        }
      }
    }
  }
  xml.object(:class => "net.sf.sail.emf.launch.ConsoleLogServiceImpl") { 
    if local_assigns[:console_post_url]
      xml.void(:property => "bundlePoster") { 
        xml.object(:class => "net.sf.sail.emf.launch.BundlePoster") { 
          xml.void(:property => "postUrl") { 
            xml.string console_post_url
          }
        }
      }
    end
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
          if local_assigns[:bundle_url]
            xml.string bundle_url
          else
            xml.string root_path(:only_path => false) + 'bundles/empty_bundle.xml'
          end
        }
      }
    }
    if local_assigns[:bundle_post_url]
      xml.void(:property => "bundlePoster") { 
        xml.object(:class => "net.sf.sail.emf.launch.BundlePoster") { 
          xml.void(:property => "postUrl") { 
            xml.string bundle_post_url
          }
        }
      }
    end
  }
  xml.object(:class => "net.sf.sail.core.service.impl.LauncherServiceImpl") { 
    xml.void(:property => "properties") { 
      xml.object(:class => "java.util.Properties") {
        all_properties.each{|name, value|
          xml.void(:method => "setProperty") { 
            xml.string name
            xml.string value
          }
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
