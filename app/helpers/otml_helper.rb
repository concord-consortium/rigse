module OtmlHelper

  def net_logo_package_name
    @jnlp_adaptor.net_logo_package_name
  end
  
  def ot_menu_display_name(object)
    if teacher_only?(object) 
      return "+ #{object.name}"
    end
    return object.name
  end
  
  def ot_refid_for(object, *prefixes)
    if object.is_a? String
      '${' + object + '}'
    else
      if prefixes.empty?
        '${' + ot_dom_id_for(object) + '}'
      else
        '${' + ot_dom_id_for(object, prefixes) + '}'
      end
    end
  end

  def ot_local_id_for(object, *prefixes)
    if object.is_a? String
      object
    else
      if prefixes.empty?
        ot_dom_id_for(object)
      else
        ot_dom_id_for(object, prefixes)
      end
    end
  end
  
  def ot_dom_id_for(component, *optional_prefixes)
    optional_prefixes.flatten!
    prefix = ''
    optional_prefixes.each { |p| prefix << "#{p.to_s}_" }
    class_name = component.class.name.split('::').last.underscore
    "#{prefix}#{class_name}_#{component.id}"
  end
  
  def data_filter_inports
    Probe::DataFilter.find(:all).collect { |df| df.otrunk_object_class }
  end
  
  def imports
    imports = %w{
      org.concord.data.state.OTDataChannelDescription
      org.concord.data.state.OTDataField
      org.concord.data.state.OTDataStore
      org.concord.data.state.OTDataTable
      org.concord.data.state.OTTimeLimitDataProducerFilter
      org.concord.datagraph.state.OTDataAxis
      org.concord.datagraph.state.OTDataCollector
      org.concord.otrunk.graph.OTDataCollectorViewConfig
      org.concord.datagraph.state.OTDataGraph
      org.concord.datagraph.state.OTDataGraphable
      org.concord.datagraph.state.OTMultiDataGraph
      org.concord.datagraph.state.OTPluginView
      org.concord.framework.otrunk.view.OTFrame
      org.concord.framework.otrunk.wrapper.OTInt
      org.concord.framework.otrunk.wrapper.OTBoolean
      org.concord.framework.otrunk.wrapper.OTBlob
      org.concord.graph.util.state.OTDrawingTool2
      org.concord.otrunk.OTSystem
      org.concord.otrunk.control.OTButton
      org.concord.otrunk.ui.OTCardContainer
      org.concord.otrunk.ui.OTTabContainer
      org.concord.otrunk.ui.OTChoice
      org.concord.otrunk.ui.swing.OTChoiceViewConfig
      org.concord.otrunk.ui.OTCurriculumUnit
      org.concord.otrunk.ui.OTText
      org.concord.otrunk.ui.OTRITESContainer
      org.concord.otrunk.ui.OTSection
      org.concord.otrunk.ui.menu.OTMenu
      org.concord.otrunk.ui.menu.OTMenuRule
      org.concord.otrunk.ui.menu.OTNavBar
      org.concord.otrunk.ui.question.OTQuestion
      org.concord.otrunk.view.OTFolderObject
      org.concord.otrunk.view.OTViewBundle
      org.concord.otrunk.view.OTViewChild
      org.concord.otrunk.view.OTViewEntry
      org.concord.otrunk.view.OTViewMode
      org.concord.otrunk.view.document.OTCompoundDoc
      org.concord.otrunk.view.document.OTCssText
      org.concord.otrunk.view.document.OTDocumentViewConfig
      org.concord.otrunk.view.document.edit.OTDocumentEditViewConfig
      org.concord.otrunkmw.OTModelerPage
      org.concord.sensor.state.OTZeroSensor
      org.concord.sensor.state.OTDeviceConfig
      org.concord.sensor.state.OTExperimentRequest
      org.concord.sensor.state.OTInterfaceManager
      org.concord.sensor.state.OTSensorDataProxy
      org.concord.sensor.state.OTSensorRequest
      org.concord.otrunk.biologica.OTWorld
      org.concord.otrunk.biologica.OTOrganism
      org.concord.otrunk.biologica.OTStaticOrganism
      org.concord.otrunk.biologica.OTChromosome
      org.concord.otrunk.biologica.OTChromosomeZoom
      org.concord.otrunk.biologica.OTBreedOffspring
      org.concord.otrunk.biologica.OTPedigree
      org.concord.otrunk.biologica.OTMultipleOrganism
      org.concord.otrunk.biologica.OTFamily
      org.concord.otrunk.biologica.OTSex
      org.concord.otrunk.labbook.OTLabbook
      org.concord.otrunk.labbook.OTLabbookView
      org.concord.otrunk.labbook.OTLabbookButton
      org.concord.otrunk.labbook.OTLabbookEntryChooser
      org.concord.otrunk.util.OTLabbookBundle
      org.concord.otrunk.util.OTLabbookEntry
      org.concord.otrunk.script.OTScriptEngineBundle
      org.concord.otrunk.script.OTScriptEngineEntry
      org.concord.otrunk.script.ui.OTScriptButton
      org.concord.otrunk.script.jruby.OTJRuby
      org.concord.otrunk.script.js.OTJavascript
      org.concord.otrunk.script.ui.OTScriptVariable
      org.concord.otrunk.script.ui.OTScriptVariableComponent
      org.concord.otrunk.script.ui.OTScriptVariableRealObject
      org.concord.otrunk.script.ui.OTScriptObject
      org.concord.otrunk.script.ui.OTScriptVariableView
      org.concord.smartgraph.OTSmartGraphTool
      org.concord.multimedia.state.OTSoundGrapherModel
    } + data_filter_inports + (@otrunk_imports || []).uniq
    imports <<  "org.concord.#{net_logo_package_name}.OTNLogoModel"
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
      ['rites_container', 'org.concord.otrunk.ui.OTRITESContainer', 'org.concord.otrunk.ui.OTRITESContainerView'],
      ['curriculum_unit_view', 'org.concord.otrunk.ui.OTCurriculumUnit', 'org.concord.otrunk.ui.swing.OTCurriculumUnitView'],
      ['section_view', 'org.concord.otrunk.ui.OTSection', 'org.concord.otrunk.ui.swing.OTSectionView'],
      ['menu_page_view', 'org.concord.otrunk.ui.menu.OTMenu', 'org.concord.otrunk.ui.menu.OTMenuPageView'],
      ['menu_accordion_section_view', 'org.concord.otrunk.ui.menu.OTMenu', 'org.concord.otrunk.swingx.OTMenuAccordionSectionView'],
      ['menu_section_view', 'org.concord.otrunk.ui.menu.OTMenu', 'org.concord.otrunk.ui.menu.OTMenuSectionView'],
      ['menu_page_expand_view', 'org.concord.otrunk.ui.menu.OTMenu', 'org.concord.otrunk.ui.menu.OTMenuPageExpandView'],
      ['card_container_view', 'org.concord.otrunk.ui.OTCardContainer', 'org.concord.otrunk.ui.swing.OTCardContainerView'],
      ['tab_container_view','org.concord.otrunk.ui.OTTabContainer', 'org.concord.otrunk.ui.swing.OTTabContainerView'],
      ['nav_bar', 'org.concord.otrunk.ui.menu.OTNavBar', 'org.concord.otrunk.ui.menu.OTNavBarView'],
      ['modeler_page_view', 'org.concord.otrunkmw.OTModelerPage', 'org.concord.otrunkmw.OTModelerPageView'],
      ['n_logo_model', "org.concord.#{net_logo_package_name}.OTNLogoModel", "org.concord.#{net_logo_package_name}.OTNLogoModelView"],
      ['biologica_world', 'org.concord.otrunk.biologica.OTWorld', 'org.concord.otrunk.ui.swing.OTNullView'],
      ['biologica_organism', 'org.concord.otrunk.biologica.OTOrganism', 'org.concord.otrunk.ui.swing.OTNullView'],
      ['biologica_static_organism', 'org.concord.otrunk.biologica.OTStaticOrganism', 'org.concord.otrunk.biologica.ui.OTStaticOrganismView'],
      ['biologica_chromosome','org.concord.otrunk.biologica.OTChromosome','org.concord.otrunk.biologica.ui.OTChromosomeView'],
      ['biologica_chromosome_zoom','org.concord.otrunk.biologica.OTChromosomeZoom','org.concord.otrunk.biologica.ui.OTChromosomeZoomView'],
      ['biologica_breed_offspring','org.concord.otrunk.biologica.OTBreedOffspring','org.concord.otrunk.biologica.ui.OTBreedOffspringView'],
      ['biologica_pedigree','org.concord.otrunk.biologica.OTPedigree','org.concord.otrunk.biologica.ui.OTPedigreeView'],
      ['biologica_multiple_organism','org.concord.otrunk.biologica.OTMultipleOrganism','org.concord.otrunk.biologica.ui.OTMultipleOrganismView'],
      ['biologica_family','org.concord.otrunk.biologica.OTFamily','org.concord.otrunk.ui.swing.OTNullView'],
      ['biologica_sex','org.concord.otrunk.biologica.OTSex','org.concord.otrunk.biologica.ui.OTSexView'],
      ['lab_book_button_view', 'org.concord.otrunk.labbook.OTLabbookButton', 'org.concord.otrunk.labbook.ui.OTLabbookButtonView'],
      ['lab_book_view' ,'org.concord.otrunk.labbook.OTLabbook', 'org.concord.otrunk.labbook.ui.OTLabbookView'],
      ['lab_book_entry_chooser', 'org.concord.otrunk.labbook.OTLabbookEntryChooser', 'org.concord.otrunk.labbook.ui.OTLabbookEntryChooserView'],
      ['smart_graph_tool_view', 'org.concord.smartgraph.OTSmartGraphTool', 'org.concord.smartgraph.OTSmartGraphToolHiddenView'],
      ['script_button_view', 'org.concord.otrunk.script.ui.OTScriptButton', 'org.concord.otrunk.script.ui.OTScriptButtonView'],
      ['script_object_view', 'org.concord.otrunk.script.ui.OTScriptObject', 'org.concord.otrunk.script.ui.OTScriptObjectView'],
      ['sound_grapher_view', 'org.concord.multimedia.state.OTSoundGrapherModel', 'org.concord.multimedia.state.ui.OTSoundGrapherModelView']
    ] + (@otrunk_view_entries || []).uniq
  end
  
  def authoring_view_entries
    [
      ['text_edit_edit_view', 'org.concord.otrunk.ui.OTText', 'org.concord.otrunk.ui.swing.OTTextEditEditView'],
      ['question_edit_view', 'org.concord.otrunk.ui.question.OTQuestion', 'org.concord.otrunk.ui.question.OTQuestionEditView'],
      ['choice_radio_button_edit_view', 'org.concord.otrunk.ui.OTChoice', 'org.concord.otrunk.ui.swing.OTChoiceComboBoxEditView'],
      ['lab_book_button_view', 'org.concord.otrunk.labbook.OTLabbookButton', 'org.concord.otrunk.labbook.ui.OTLabbookButtonEditView'],
#      ['data_drawing_tool2_view', 'org.concord.graph.util.state.OTDrawingTool2', 'org.concord.datagraph.state.OTDataDrawingToolView'],
#      ['blob_image_view', 'org.concord.framework.otrunk.wrapper.OTBlob', 'org.concord.otrunk.ui.swing.OTBlobImageView'],
      ['data_collector_edit_view', 'org.concord.datagraph.state.OTDataCollector', 'org.concord.otrunk.graph.OTDataCollectorEditView'],
#      ['data_graph_view', 'org.concord.datagraph.state.OTDataGraph', 'org.concord.datagraph.state.OTDataGraphView'],
#      ['data_field_view', 'org.concord.data.state.OTDataField', 'org.concord.data.state.OTDataFieldView'],
      ['data_drawing_tool_edit_view', 'org.concord.graph.util.state.OTDrawingTool', 'org.concord.otrunk.graph.OTDataDrawingToolEditView'],
#      ['multi_data_graph_view', 'org.concord.datagraph.state.OTMultiDataGraph', 'org.concord.datagraph.state.OTMultiDataGraphView'],
#      ['button_view', 'org.concord.otrunk.control.OTButton', 'org.concord.otrunk.control.OTButtonView'],
      ['data_table_edit_view', 'org.concord.data.state.OTDataTable', 'org.concord.otrunk.ui.swing.OTDataTableEditView'],
      ['udl_container_edit_view', 'org.concord.otrunk.ui.OTRITESContainer', 'org.concord.otrunk.ui.OTRITESContainerEditView'],
      ['curriculum_unit_edit_view', 'org.concord.otrunk.ui.OTCurriculumUnit', 'org.concord.otrunk.ui.swing.OTCurriculumUnitEditView'],
#      ['section_view', 'org.concord.otrunk.ui.OTSection', 'org.concord.otrunk.ui.swing.OTSectionView'],
      ['menu_page_edit_view', 'org.concord.otrunk.ui.menu.OTMenu', 'org.concord.otrunk.ui.menu.OTMenuPageEditView'],
#      ['menu_accordion_section_view', 'org.concord.otrunk.ui.menu.OTMenu', 'org.concord.otrunk.swingx.OTMenuAccordionSectionView'],
      ['menu_section_edit_view', 'org.concord.otrunk.ui.menu.OTMenu', 'org.concord.otrunk.ui.menu.OTMenuSectionEditView'],
      ['menu_page_expand_edit_view', 'org.concord.otrunk.ui.menu.OTMenu', 'org.concord.otrunk.ui.menu.OTMenuPageEditView'],
#      ['card_container_view', 'org.concord.otrunk.ui.OTCardContainer', 'org.concord.otrunk.ui.swing.OTCardContainerView'],
#      ['nav_bar', 'org.concord.otrunk.ui.menu.OTNavBar', 'org.concord.otrunk.ui.menu.OTNavBarView'],
      ['modeler_page_edit_view', 'org.concord.otrunkmw.OTModelerPage', 'org.concord.otrunkmw.OTModelerPageEditView'],
      ['n_logo_model_edit_view', "org.concord.#{net_logo_package_name}.OTNLogoModel", "org.concord.#{net_logo_package_name}.OTNLogoModelEditView"],
      ['biologica_world', 'org.concord.otrunk.biologica.OTWorld', 'org.concord.otrunk.biologica.OTWorldEditView'],
      ['biologica_organism', 'org.concord.otrunk.biologica.OTOrganism', 'org.concord.otrunk.biologica.OTOrganismEditView'],
      ['biologica_static_organism', 'org.concord.otrunk.biologica.OTStaticOrganism', 'org.concord.otrunk.biologica.ui.OTStaticOrganismEditView'],
      ['biologica_chromosome','org.concord.otrunk.biologica.OTChromosome','org.concord.otrunk.biologica.ui.OTChromosomeEditView'],
      ['biologica_chromosome_zoom','org.concord.otrunk.biologica.OTChromosomeZoom','org.concord.otrunk.biologica.ui.OTChromosomeZoomEditView'],
      ['biologica_breed_offspring','org.concord.otrunk.biologica.OTBreedOffspring','org.concord.otrunk.biologica.ui.OTBreedOffspringEditView'],
      ['biologica_pedigree','org.concord.otrunk.biologica.OTPedigree','org.concord.otrunk.biologica.ui.OTPedigreeEditView'],
      ['biologica_multiple_organism','org.concord.otrunk.biologica.OTMultipleOrganism','org.concord.otrunk.biologica.ui.OTMultipleOrganismEditView'],
      ['biologica_family','org.concord.otrunk.biologica.OTFamily','org.concord.otrunk.ui.swing.OTNullView'],
      ['biologica_sex','org.concord.otrunk.biologica.OTSex','org.concord.otrunk.biologica.ui.OTSexEditView'],
      ['smart_graph_tool_view', 'org.concord.smartgraph.OTSmartGraphTool', 'org.concord.smartgraph.OTSmartGraphToolEditView'],
      ['script_button_view', 'org.concord.otrunk.script.ui.OTScriptButton', 'org.concord.otrunk.script.ui.OTScriptButtonEditView']
    ] + (@otrunk_edit_view_entries || []).uniq
  end

  def ot_view_bundle(options={})
    @left_nav_panel_width =  options[:left_nav_panel_width] || 0
    title = "#{APP_CONFIG[:theme].capitalize}: " + options[:title] ||  "sample"
    use_scroll_pane = (options[:use_scroll_pane] || false).to_s
    authoring = options[:authoring] || false
    if authoring
      current_mode = 'authoring'
    else
      current_mode = 'student'
    end
    render :partial => "otml/ot_view_bundle", 
      :locals => { :view_entries => view_entries, 
                   :authoring_view_entries => authoring_view_entries, 
                   :use_scroll_pane => use_scroll_pane,
                   :body_width => 840,
                   :height => 700,
                   :left_nav_panel_width => @left_nav_panel_width, 
                   :title => title, 
                   :authoring => authoring, 
                   :current_mode => current_mode }
  end

  def ot_script_engine_bundle
    engines = [
      ['org.concord.otrunk.script.js.OTJavascript', 'org.concord.otrunk.script.js.OTJavascriptEngine'],
      ['org.concord.otrunk.script.jruby.OTJRuby', 'org.concord.otrunk.script.jruby.OTJRubyEngine']
    ]
    render :partial => "otml/ot_script_engine_bundle", :locals => { :engines => engines }
  end

  def ot_sharing_bundle
    render :partial => "otml/ot_sharing_bundle"
  end

  def ot_interface_manager(use_current_user = false)
    old_format = @template_format
    @template_format = :otml
    # Now that we're using the HttpCookieService, current_user.vendor_interface 
    # should be correct, even when requesting from the java client
    vendor_interface = nil
    # allow switching between using the current user and not. This way 
    # the cached otml can always have Go!Link, but the dynamic 
    # otml can use the current user's device.
    # debugger
    if use_current_user
      vendor_interface = current_user.vendor_interface
    else
      vendor_interface = Probe::VendorInterface.find_by_short_name("vernier_goio")
    end
    result = render :partial => "otml/ot_interface_manager", :locals => { :vendor_interface => vendor_interface }
    @template_format = old_format
    return result
  end

  def ot_bundles(options={})
    capture_haml do
      haml_tag :bundles do
        haml_concat ot_view_bundle(options)
        haml_concat ot_interface_manager
        haml_concat ot_script_engine_bundle
        haml_tag :OTLabbookBundle, {:local_id => 'lab_book_bundle'}
      end
    end
  end

  def ot_sensor_data_proxy(data_collector)
    probe_type = data_collector.probe_type
    capture_haml do
      haml_tag :OTSensorDataProxy, :local_id => ot_local_id_for(data_collector, :data_proxy) do
         haml_tag :request do
           haml_tag :OTExperimentRequest, :period => probe_type.period.to_s do
             haml_tag :sensorRequests do
               haml_tag :OTSensorRequest, :stepSize => probe_type.step_size.to_s, 
                :type => probe_type.ptype.to_s, :unit => probe_type.unit, :port => probe_type.port.to_s, 
                :requiredMax => probe_type.max.to_s, :requiredMin => probe_type.min.to_s,
                :displayPrecision => "#{data_collector.probe_type.display_precision}"
            end
          end
        end
      end
    end
  end
  
  # %OTDataStore{ :local_id => ot_local_id_for(data_collector, :data_store), :numberChannels => '2' }
  #   - if data_collector.data_store_values.length > 0
  #     %values
  #       - data_collector.data_store_values.each do |value|
  #         %float= value
  # 
  def generate_otml_datastore(data_collector)
    capture_haml do
      haml_tag :OTDataStore, :local_id => ot_local_id_for(data_collector, :data_store), :numberChannels => '2' do
        if data_collector.data_store_values && data_collector.data_store_values.length > 0
          haml_tag :values do
            data_collector.data_store_values.each do |value|
              haml_tag(:float, :<) do
                haml_concat(value)
              end
            end
          end
        end
      end
    end
  end
  
  def otml_for_time_limit_filter(limit, seconds)
    if seconds
      ms = (seconds * 1000).to_i
    else
      ms = 0
    end 
    capture_haml do
      if limit
        haml_tag :OTTimeLimitDataProducerFilter, :sourceChannel => "1", :timeLimit => ms do
          haml_tag :source do
            if block_given? 
              yield
            end
          end
        end
      else
        if block_given? 
          yield
        end
      end
    end
  end

  def otml_for_calibration_filter(calibration)
    if filter = calibration.data_filter
      capture_haml do
        ot_name = filter.otrunk_object_class.split(".")[-1]
        haml_tag ot_name.to_sym, :sourceChannel => "1" do
          haml_tag :source do
            if block_given? 
              yield
            end
          end
        end
      end
    end
  end
  
  def preview_warning
    APP_CONFIG[:otml_preview_message] || "Your data will not be saved"
  end
  
  def otml_css_path(base="stylesheets",name="otml")
    theme = APP_CONFIG[:theme]
    file = "#{name}.css"
    default_path = File.join(base,file)
    if theme
      themed_path = File.join(base,'themes', theme, file)
      if File.exists? File.join(RAILS_ROOT,'public',themed_path)
        return "/#{themed_path}"
      end
    end
    return "/#{default_path}"
  end
end
