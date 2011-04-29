require 'spec_helper'

describe "/pages/_show.otml.haml" do
  # include Page
  include ApplicationHelper

  before(:each) do
    
    # # testing embedding of page elements doesn't work yet, as element partials are called with
    # # html format, not otml...
    # template.stub!(:edit_menu_for).and_return("edit menu")
    #     dataTable = assigns[:data_table] = @data_table = stub_model(Embeddable::DataTable,
    #       :new_record? => false, :id => 1, :name => "Data Table", :description => "Desc", :column_count => 4, :visible_rows => 9, :column_names => 'One,Two,Three,Four', :column_data => '', :data_collector_id => nil
    #     )
    #     
    #     pageElement = stub_model(PageElement,
    #       :is_enabled? => true, :embeddable => dataTable
    #     )
    
    section = stub_model(Section,
      :name => "Test Section"
    )
    
    
    assigns[:page] = @page = stub_model(Page,
      :new_record? => false, :id => 1, :name => "Test Page", :section => section
    )
  end

  it "renders a container OTCompundDoc with a reference to its content object" do
    render :locals => { :page => @page, :teacher_mode => false }
    response.capture("page_#{dom_id_for(@page)}").should have_tag("OTCompoundDoc[local_id=?][name=?]", dom_id_for(@page), "Test Page") do
      with_tag("bodyText") do
        with_tag("object[refid=?]","${tab_content_#{dom_id_for(@page)}}")
      end
    end
  end
  
  it "renders page content as an OTCompundDoc with section" do
    render :locals => { :page => @page, :teacher_mode => false }
    response.capture(:library).should have_tag("OTCompoundDoc[local_id=?][name=?]", "tab_content_#{dom_id_for(@page)}", "Test Page") do
      with_tag("div[id=?]", "content") do
        with_tag("p[class=?]","page_title", :text => "Test Section")
      end
    end
  end
end
