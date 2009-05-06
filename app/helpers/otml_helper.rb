module OtmlHelper

  def ot_refid_for(object, *prefixes)
    if object.is_a? String
      '${' + object + '}'
    else
      if prefixes.empty?
        '${' + dom_id_for(object) + '}'
      else
        '${' + dom_id_for(object, prefixes) + '}'
      end
    end
  end

  def ot_local_id_for(object, *prefixes)
    if object.is_a? String
      object
    else
      if prefixes.empty?
        dom_id_for(object)
      else
        dom_id_for(object, prefixes)
      end
    end
  end
  
  def imports
    imports = %w{
      org.concord.otrunk.OTSystem
      org.concord.framework.otrunk.view.OTFrame
      org.concord.otrunk.view.OTViewEntry
      org.concord.otrunk.view.OTViewBundle
      org.concord.otrunk.view.document.OTDocumentViewConfig
      org.concord.otrunk.view.document.OTCssText
      org.concord.sensor.state.OTDeviceConfig
      org.concord.sensor.state.OTExperimentRequest
      org.concord.sensor.state.OTInterfaceManager
      org.concord.sensor.state.OTSensorDataProxy
      org.concord.sensor.state.OTSensorRequest
      org.concord.otrunk.view.document.OTCompoundDoc
      org.concord.otrunk.ui.OTText
      org.concord.otrunk.ui.question.OTQuestion
      org.concord.otrunk.ui.OTChoice
      org.concord.graph.util.state.OTDrawingTool2
      org.concord.framework.otrunk.wrapper.OTBlob
      org.concord.data.state.OTDataTable
      org.concord.data.state.OTDataChannelDescription
      org.concord.data.state.OTDataField
      org.concord.data.state.OTDataStore
      org.concord.datagraph.state.OTDataAxis
      org.concord.datagraph.state.OTDataCollector
      org.concord.datagraph.state.OTDataGraph
      org.concord.datagraph.state.OTDataGraphable
      org.concord.datagraph.state.OTMultiDataGraph
      org.concord.datagraph.state.OTPluginView
      org.concord.otrunk.control.OTButton
      org.concord.sensor.state.OTZeroSensor
      org.concord.otrunk.ui.OTUDLContainer
      org.concord.otrunk.ui.OTCardContainer
      org.concord.otrunk.ui.OTCurriculumUnit
      org.concord.otrunk.ui.OTSection
      org.concord.otrunk.ui.menu.OTMenu
      org.concord.otrunk.ui.menu.OTMenuRule
      org.concord.otrunk.ui.menu.OTNavBar
      org.concord.otrunk.view.OTViewChild
    }
  end
  
  def ot_imports
    capture_haml do
      haml_tag :imports do
        imports.each do |import|
          haml_tag :import, :/, :class => import
        end
      end
    end
  end

  def view_entries
    [
      ['text_edit_view', 'org.concord.otrunk.ui.OTText', 'org.concord.otrunk.ui.swing.OTTextEditView'],
      ['question_view', 'org.concord.otrunk.ui.question.OTQuestion', 'org.concord.otrunk.ui.question.OTQuestionView'],
      ['choice_radio_button_view', 'org.concord.otrunk.ui.OTChoice', 'org.concord.otrunk.ui.swing.OTChoiceRadioButtonView'],
      ['data_drawing_tool2_view', 'org.concord.graph.util.state.OTDrawingTool2', 'org.concord.datagraph.state.OTDataDrawingToolView'],
      ['blob_image_view', 'org.concord.framework.otrunk.wrapper.OTBlob', 'org.concord.otrunk.ui.swing.OTBlobImageView'],
      ['data_collector_view', 'org.concord.datagraph.state.OTDataCollector', 'org.concord.datagraph.state.OTDataCollectorView'],
      ['data_graph_view', 'org.concord.datagraph.state.OTDataGraph', 'org.concord.datagraph.state.OTDataGraphView'],
      ['data_field_view', 'org.concord.data.state.OTDataField', 'org.concord.data.state.OTDataFieldView'],
      ['data_drawing_tool_view', 'org.concord.graph.util.state.OTDrawingTool', 'org.concord.datagraph.state.OTDataDrawingToolView'],
      ['multi_data_graph_view', 'org.concord.datagraph.state.OTMultiDataGraph', 'org.concord.datagraph.state.OTMultiDataGraphView'],
      ['button_view', 'org.concord.otrunk.control.OTButton', 'org.concord.otrunk.control.OTButtonView'],
      ['data_table_view', 'org.concord.data.state.OTDataTable', 'org.concord.data.state.OTDataTableView'],
      ['udl_container', 'org.concord.otrunk.ui.OTUDLContainer', 'org.concord.otrunk.ui.OTUDLContainerView'],
      ['curriculum_unit_view', 'org.concord.otrunk.ui.OTCurriculumUnit', 'org.concord.otrunk.ui.swing.OTCurriculumUnitView'],
      ['section_view', 'org.concord.otrunk.ui.OTSection', 'org.concord.otrunk.ui.swing.OTSectionView'],
      ['menu_page_view', 'org.concord.otrunk.ui.menu.OTMenu', 'org.concord.otrunk.ui.menu.OTMenuPageView'],
      ['menu_accordion_section_view', 'org.concord.otrunk.ui.menu.OTMenu', 'org.concord.otrunk.swingx.OTMenuAccordionSectionView'],
      ['menu_section_view', 'org.concord.otrunk.ui.menu.OTMenu', 'org.concord.otrunk.ui.menu.OTMenuSectionView'],
      ['menu_page_expand_view', 'org.concord.otrunk.ui.menu.OTMenu', 'org.concord.otrunk.ui.menu.OTMenuPageExpandView'],
      ['card_container_view', 'org.concord.otrunk.ui.OTCardContainer', 'org.concord.otrunk.ui.swing.OTCardContainerView'],
      ['nav_bar', 'org.concord.otrunk.ui.menu.OTNavBar', 'org.concord.otrunk.ui.menu.OTNavBarView']
    ]
  end

  def ot_view_bundle(options={})
    @left_nav_panel_width =  options[:left_nav_panel_width] || 0
    title = options[:title] || 'RITES sample'
    render :partial => "otml/ot_view_bundle", :locals => { :view_entries => view_entries, :left_nav_panel_width => @left_nav_panel_width, :title => title }
  end

  def ot_script_engine_bundle
    engines = [
      'org.concord.otrunk.script.js.OTJavascript', 'org.concord.otrunk.script.js.OTJavascriptEngine',
      'org.concord.otrunk.script.jruby.OTJRuby', 'org.concord.otrunk.script.jruby.OTJRubyEngine'
    ]
    render :partial => "otml/ot_script_engine_bundle", :locals => { :engines => engines }
  end

  def ot_sharing_bundle
    render :partial => "otml/ot_sharing_bundle"
  end

  def ot_interface_manager
    vendor_interface = current_user.vendor_interface
    render :partial => "otml/ot_interface_manager", :locals => { :vendor_interface => vendor_interface }
  end

  def ot_bundles(options={})
    capture_haml do
      haml_tag :bundles do
        haml_concat ot_view_bundle(options)
        haml_concat ot_interface_manager
      end
    end
  end
end


