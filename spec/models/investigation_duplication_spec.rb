require File.expand_path('../../spec_helper', __FILE__)

describe Investigation do
  before(:each) do
    @valid_attributes = {
      :name => "test investigation",
      :description => "new decription"
    }
  end

  describe "after duplication the" do

    def duplicate_investigation
      @original_author = Factory :user
      @new_author = Factory :user
      @source_investigation = Factory :investigation, { :user => @original_author }
      @source_investigation.activities << (Factory :activity, { :user => @original_author })
      @source_investigation.activities[0].sections << (Factory :section, {:user => @original_author})
      @source_investigation.activities[0].sections[0].pages << (Factory :page, {:user => @original_author})

      open_response = (Factory :open_response, {:user => @original_author})
      open_response.pages << @source_investigation.activities[0].sections[0].pages[0]

      draw_tool = (Factory :drawing_tool, {:user => @original_author, :background_image_url => "https://lh4.googleusercontent.com/-xcAHK6vd6Pc/Tw24Oful6sI/AAAAAAAAB3Y/iJBgijBzi10/s800/4757765621_6f5be93743_b.jpg"})
      draw_tool.pages << @source_investigation.activities[0].sections[0].pages[0]
      snapshot_button = (Factory :lab_book_snapshot, {:user => @original_author, :target_element => draw_tool})
      snapshot_button.pages << @source_investigation.activities[0].sections[0].pages[0]

      prediction_graph = (Factory :data_collector, {:user => @original_author})
      prediction_graph.pages << @source_investigation.activities[0].sections[0].pages[0]
      displaying_graph = (Factory :data_collector, {:user => @original_author, :prediction_graph_source => prediction_graph})
      displaying_graph.pages << @source_investigation.activities[0].sections[0].pages[0]

      @source_investigation.reload
      @dest_investigation = @source_investigation.duplicate(@new_author)
      @dest_investigation.save
      @dest_investigation.reload
    end

    before(:each) do
      duplicate_investigation
    end

    describe "original investigation should" do
      it "have pages" do
        expect(@source_investigation.pages.size).to be >= 1
      end
      it "have a name" do
        expect(@source_investigation.name).not_to be_nil
      end

      it "not be changeable by the new author" do
        expect(@source_investigation).not_to be_changeable(@new_author)
      end
    end

    describe "new investigation should" do
      it "exist" do
        expect(@dest_investigation).not_to be_nil
      end

      it "have a similar name" do
        expect(@dest_investigation.name).to match(@source_investigation.name)
        expect(@dest_investigation.name).to match(/copy/i)
      end

      it "not have the same name" do
        expect(@dest_investigation.name).not_to eq(@source_investigation.name)
      end

      it "have a unique id" do
        expect(@dest_investigation.id).not_to be(@source_investigation.id)
      end

      it "be changeable by the new author" do
        expect(@dest_investigation).to be_changeable(@new_author)
        expect(@dest_investigation).not_to be_changeable(@original_author)
      end

      it "have pages which are changable by the new author" do
        expect(@dest_investigation.pages[0]).not_to be_nil
        expect(@dest_investigation.pages[0]).to be_changeable(@new_author)
        expect(@dest_investigation.pages[0]).not_to be_changeable(@original_author)
      end

      it "have an open response which is changeable by the new author" do
        expect(@dest_investigation.pages[0].open_responses[0]).not_to be_nil
        expect(@dest_investigation.pages[0].open_responses[0]).to be_changeable(@new_author)
        expect(@dest_investigation.pages[0].open_responses[0]).not_to be_changeable(@original_author)
      end

      it "have a page_element which is changeable by the new author" do
        expect(@dest_investigation.pages.first.page_elements.first).not_to be_nil
        expect(@dest_investigation.pages.first.page_elements.first).to be_changeable(@new_author)
        expect(@dest_investigation.pages.first.page_elements.first).not_to be_changeable(@original_author)
      end

      it "should have a lab book button which points to the new investigation drawing tool" do
        source_draw_tool = @source_investigation.pages.first.drawing_tools.first
        dest_draw_tool = @dest_investigation.pages.first.drawing_tools.first
        source_snap = @source_investigation.pages.first.lab_book_snapshots.first
        dest_snap = @dest_investigation.pages.first.lab_book_snapshots.first
        expect(dest_snap.target_element).to eq(dest_draw_tool)
      end

      it "should have a data collector which points to the new investigation prediction graph" do
        source_prediction_graph = @source_investigation.pages.first.data_collectors.first
        dest_prediction_graph = @dest_investigation.pages.first.data_collectors.first
        source_dc = @source_investigation.pages.first.data_collectors.last
        dest_dc = @dest_investigation.pages.first.data_collectors.last
        expect(dest_dc.prediction_graph_source).to eq(dest_prediction_graph)
      end
    end
  end

end
