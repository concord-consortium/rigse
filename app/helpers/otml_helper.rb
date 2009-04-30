module OtmlHelper

  def otml_imports
    imports = %w{
      org.concord.otrunk.OTSystem
      org.concord.framework.otrunk.view.OTFrame
      org.concord.otrunk.view.OTViewEntry
      org.concord.otrunk.view.OTViewBundle
      org.concord.otrunk.view.document.OTCompoundDoc
      org.concord.otrunk.ui.OTText
      org.concord.otrunk.ui.question.OTQuestion
      org.concord.otrunk.view.document.OTDocumentViewConfig
    }
    capture_haml do
      haml_tag :imports do
        imports.each do |import|
          haml_tag :import, :/, :class => import
        end
      end
    end
  end

  def otml_bundles
    view_entries = [
      ['org.concord.otrunk.ui.OTText', 'org.concord.otrunk.ui.swing.OTTextEditView'],
      ['org.concord.otrunk.ui.question.OTQuestion', 'org.concord.otrunk.ui.question.OTQuestionView']
    ]
    capture_haml do
      haml_tag :bundles do
        haml_tag :OTViewBundle, :showLeftPanel => 'false' do
          haml_tag :frame do
            haml_tag :OTFrame, :/, :useScrollPane => 'false'
          end
          haml_tag :viewEntries do
            view_entries.each do |view_entry|
              haml_tag :OTViewEntry, :/, :objectClass => view_entry[0], :viewClass => view_entry[1]
            end
            haml_tag :OTDocumentViewConfig, :objectClass => 'org.concord.otrunk.view.document.OTDocument', 
              :viewClass =>'org.concord.otrunk.view.document.OTDocumentView',
              :css => <<HEREDOC
body { background-color:#FFFFFF; color:#333333; font-family:Tahoma,'Trebuchet MS',sans-serif; line-height:1.5em; }
h1 { color:#FFD32C; font-size:1.5em; margin-bottom:0px; }
h2 { color:#FFD32C; font-size:1.3em; margin-bottom:0px; }
h2 { color:#FFD32C; font-size:1.1em; margin: 2em 0em 1em 0em; }
p { font-size:1.0em; margin: 10px 4px 10px 4px; }
#content { margin:5px; padding:5px; }
HEREDOC
          end
        end
      end
    end
  end
end