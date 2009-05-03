module OtmlHelper

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
    }
  end
  
  def otml_imports
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
      ['org.concord.otrunk.ui.OTText', 'org.concord.otrunk.ui.swing.OTTextEditView'],
      ['org.concord.otrunk.ui.question.OTQuestion', 'org.concord.otrunk.ui.question.OTQuestionView'],
      ['org.concord.otrunk.ui.OTChoice', 'org.concord.otrunk.ui.swing.OTChoiceRadioButtonView'],
      ['org.concord.graph.util.state.OTDrawingTool2', 'org.concord.datagraph.state.OTDataDrawingToolView'],
      ['org.concord.framework.otrunk.wrapper.OTBlob', 'org.concord.otrunk.ui.swing.OTBlobImageView'],
      ['org.concord.datagraph.state.OTDataCollector', 'org.concord.datagraph.state.OTDataCollectorView'],
      ['org.concord.datagraph.state.OTDataGraph', 'org.concord.datagraph.state.OTDataGraphView'],
      ['org.concord.data.state.OTDataField', 'org.concord.data.state.OTDataFieldView'],
      ['org.concord.graph.util.state.OTDrawingTool', 'org.concord.datagraph.state.OTDataDrawingToolView'],
      ['org.concord.datagraph.state.OTMultiDataGraph', 'org.concord.datagraph.state.OTMultiDataGraphView'],
      ['org.concord.otrunk.control.OTButton', 'org.concord.otrunk.control.OTButtonView'],
      ['org.concord.data.state.OTDataTable', 'org.concord.data.state.OTDataTableView']
    ]
  end

  def ot_view_bundle
    render :partial => "otml/ot_view_bundle", :locals => { :view_entries => view_entries }
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

  def ot_bundles
    capture_haml do
      haml_tag :bundles do
        haml_concat ot_view_bundle
        haml_concat ot_interface_manager
      end
    end
  end
end


