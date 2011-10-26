require File.expand_path('../../../../spec_helper', __FILE__)

describe Embeddable::Smartgraph::RangeQuestionsController do

  it_should_behave_like 'an embeddable controller'

  def with_tags_like_an_otml_smartgraph_range_question
    assert_select('OTQuestion') do
      assert_select('prompt') do
        assert_select('OTCompoundDoc') do
          assert_select('bodyText')
        end
      end
      assert_select('input') do
        assert_select('OTCompoundDoc') do
          assert_select('documentRefs') do
            assert_select('OTText')
            assert_select('OTScriptButton') do
              assert_select('script') do
                assert_select('OTJRuby') do
                  assert_select('script')
                end
              end
              assert_select('scriptVariables') do
                assert_select('OTScriptVariableRealObject') do
                  assert_select('reference') do
                    assert_select('OTSmartGraphTool') do
                      assert_select('dataCollector')
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
