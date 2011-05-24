xml.otrunk(:id => "11111111-2222-3333-4444-555555555555") { 
  xml.imports { 
    xml.import :class => "org.concord.otrunk.OTIncludeRootObject"
    xml.import :class => "org.concord.otrunk.OTSystem"
    xml.import :class => "org.concord.otrunk.OTInclude"
    xml.import :class => "org.concord.sensor.state.OTDeviceConfig"
    xml.import :class => "org.concord.sensor.state.OTInterfaceManager"
    xml.import :class => "org.concord.otrunk.overlay.OTOverlay"
    xml.import :class => "org.concord.otrunk.view.document.OTCompoundDoc"
  }

  xml.objects { 
    xml.OTSystem(:local_id => "system") { 
      xml.includes { 
        if teacher_mode && runnable.class == Investigation 
          xml.OTInclude :href => investigation_teacher_otml_url(runnable)
        else
          # FIXME we need to pass options such as teacher_mode 
          # in a a more maintainable, unified manner
          xml.OTInclude :href => polymorphic_url(
              runnable, 
              :format => :otml, 
              :teacher_mode => teacher_mode
          )
        end
      }

      xml.bundles {
        # FIXME This should probably get figured out in a more dynamic way, since if anyone ever changes ot_bundles() in otml_helper.rb
        # this will need to be updated correspondingly.
        xml.object :refid => "#{runnable.uuid}!/view_bundle"
        # unless it changes, the second bundle is the interface manager
        # xml.object :refid => "#{runnable.uuid}!/interface_manager"
        xml << ot_interface_manager(true)
        xml.object :refid => "#{runnable.uuid}!/lab_book_bundle"
        xml.object :refid => "#{runnable.uuid}!/script_engine_bundle"
      }

      # FIXME This should probably get figured out in a more dynamic way, 
      # since if we ever start adding overlays,
      # this will need to be updated correspondingly each time one is added.
      xml.overlays { 
        
        # remove the "preview only warning" if user data is going be saved.
        xml.OTOverlay {  
          xml.deltaObjectMap {
            xml.entry(:key => "#{runnable.uuid}!/preview_warning") {
              xml.OTCompoundDoc {
                xml.bodyText {
                  ""
                }
              }
            }
          }
        }
      }

      xml.root { 
        root_object_local_id ||= 'system/root'
        xml.object :refid => "#{runnable.uuid}!/#{root_object_local_id}"
      }
    }
  }
}
