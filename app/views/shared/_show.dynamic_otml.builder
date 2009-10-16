xml.otrunk(:id => "11111111-2222-3333-4444-555555555555") { 
  xml.imports { 
    xml.import :class => "org.concord.otrunk.OTIncludeRootObject"
    xml.import :class => "org.concord.otrunk.OTSystem"
    xml.import :class => "org.concord.otrunk.OTInclude"
    xml.import :class => "org.concord.otrunk.user.OTUserObject"
  }

  xml.objects { 
    xml.OTSystem(:local_id => "system") { 
      xml.includes { 
        if teacher_mode && runnable.class == Investigation 
          xml.OTInclude :href => investigation_teacher_otml_url(runnable)
        else
          xml.OTInclude :href => polymorphic_url(runnable, :format => :otml, :teacher_mode => teacher_mode)
        end
      }
      xml.bundles {
        # FIXME This should probably get figured out in a more dynamic way, since if anyone ever changes ot_bundles() in otml_helper.rb
        # this will need to be updated correspondingly.
        xml.object :refid => "#{runnable.uuid}!/system/bundles[0]"
        # unless it changes, the second bundle is the interface manager
        # xml.object :refid => "#{runnable.uuid}!/system/bundles[1]"
        xml << ot_interface_manager(true)
        xml.object :refid => "#{runnable.uuid}!/system/bundles[2]"
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
