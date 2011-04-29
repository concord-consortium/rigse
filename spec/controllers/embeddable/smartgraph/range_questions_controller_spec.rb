require 'spec_helper'

describe Embeddable::Smartgraph::RangeQuestionsController do

  it_should_behave_like 'an embeddable controller'

  def with_tags_like_an_otml_smartgraph_range_question
    with_tag('OTQuestion') do
      with_tag('prompt') do
        with_tag('OTCompoundDoc') do
          with_tag('bodyText')
        end
      end
      with_tag('input') do
        with_tag('OTCompoundDoc') do
          with_tag('documentRefs') do
            with_tag('OTText')
            with_tag('OTScriptButton') do
              with_tag('script') do
                with_tag('OTJRuby') do
                  with_tag('script')
                end
              end
              with_tag('scriptVariables') do
                with_tag('OTScriptVariableRealObject') do
                  with_tag('reference') do
                    with_tag('OTSmartGraphTool') do
                      with_tag('dataCollector')
                    end
                  end
                end
              end
            end
          end 
        end
      end
    end
  end

end

# %OTQuestion{:local_id => ot_local_id_for(range_question), :name => range_question.name }
#   %prompt
#     %OTCompoundDoc
#       %bodyText= range_question.prompt
#   %input
#     %OTCompoundDoc{ :name => "Smart graph number", :showEditBar => "false" }
#       %documentRefs
#         %OTText{ :local_id => ot_local_id_for(range_question, :response_input), :text => "" }
#         %OTScriptButton{ :local_id => ot_local_id_for(range_question, :check_answer_button), :text => "Check answer" }
#           %script
#             %OTJRuby
#               %script= h(range_question.script_text)
#           %scriptVariables
#             %OTScriptVariableRealObject{ :name => "smart" }
#               %reference
#                 %OTSmartGraphTool{ :local_id => ot_local_id_for(range_question, :smartgraph_tool), :name => "smart"}
#                   %dataCollector= render_scoped_reference(range_question.data_collector)
#             %OTScriptVariable{ :name => "smart_graph_range_response" }
#               %reference
#                 %OTBlob{ :local_id => ot_local_id_for(range_question, :range_response), :src => "http://continuum.concord.org/otrunk/examples/LOOPS/scripts/smart_graph_range_response.rb" }
#             %OTScriptVariable{ :name => "otrunk_ruby_script_tools" }
#               %reference
#                 %OTBlob{ :local_id => ot_local_id_for(range_question, :script_tools), :src => "http://continuum.concord.org/otrunk/examples/LOOPS/scripts/otrunk_ruby_script_tools.rb" }
#             %OTScriptVariable{ :name => "graph" }
#               %reference
#                 = render_scoped_reference(range_question.data_collector)
#             %OTScriptVariable{ :name => "times_incorrect" }
#               %reference
#                 %OTInt{ :value => "0" }
#             %OTScriptVariable{ :name => "correct" }
#               %reference
#                 %OTBoolean{ :value => "true" }
#             %OTScriptVariable{ :name => "question" }
#               %reference
#                 %object{ :refid => ot_refid_for(range_question) }
#             %OTScriptVariable{ :name => "text_field" }
#               %reference
#                 %object{ :refid => ot_refid_for(range_question, :response_input) }
#         /
#           %OTScriptButton{ :local_id => ot_local_id_for(range_question, :author_setup_button), :text => "Setup" }
#             %script
#               %OTJavascript{ :src => "http://continuum.concord.org/otrunk/examples/LOOPS/scripts/set-up-smartgraph-button-script.js" }
#             %scriptVariables
#               %OTScriptVariable{ :name => "text_field" }
#                 %reference
#                   %object{ :refid => ot_refid_for(range_question, :response_input) }
#               %OTScriptVariable{ :name => "script_button" }
#                 %reference
#                   %object{ :refid => ot_refid_for(range_question, :check_answer_button) }
#               %OTScriptVariableComponent{ :name => "script_button_component" }
#                 %reference
#                   %object{ :refid => ot_refid_for(range_question, :check_answer_button) }
#               %OTScriptVariable{ :name => "smart_graph_range_response" }
#                 %reference
#                   %object{ :refid => ot_refid_for(range_question, :range_response) }
#               %OTScriptVariable{ :name => "otrunk_ruby_script_tools" }
#                 %reference
#                   %object{ :refid => ot_refid_for(range_question, :script_tools) }
#       %bodyText
#         - if range_question.answer_style == "number"
#           %object{ :refid => ot_refid_for(range_question, :response_input) }
#           %br
#         %object{ :refid => ot_refid_for(range_question, :check_answer_button) }
#         %br
#         %object{ :refid => ot_refid_for(range_question, :smartgraph_tool) }
#   %context= render_scoped_reference(range_question.data_collector)
# 
