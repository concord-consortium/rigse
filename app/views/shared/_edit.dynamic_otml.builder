xml.otrunk(:id => "11111111-2222-3333-4444-555555555555") { 
  xml.imports { 
    xml.import :class => "org.concord.otrunk.OTIncludeRootObject"
    xml.import :class => "org.concord.otrunk.OTSystem"
    xml.import :class => "org.concord.otrunk.OTInclude"
    xml.import :class => "org.concord.sensor.state.OTDeviceConfig"
    xml.import :class => "org.concord.sensor.state.OTInterfaceManager"
  }

  xml.objects { 
    xml.OTSystem(:local_id => "system") { 
      xml.includes { 
        if local_assigns[:teacher_mode] && runnable.class == Investigation 
          xml.OTInclude :href => investigation_teacher_otml_url(runnable)
        else
          xml.OTInclude :href => polymorphic_url(runnable, :format => :otml, :teacher_mode => local_assigns[:teacher_mode], :action => 'edit')
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
      xml.overlays { 
        # FIXME This should probably get figured out in a more dynamic way, since if we ever start adding overlays,
        # this will need to be updated correspondingly each time one is added.
      }
      xml.root { 
        xml.object :refid => "#{runnable.uuid}!/system/root"
      }
    }
  }
}
