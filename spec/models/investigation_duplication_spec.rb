require 'spec_helper'

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
        @source_investigation.pages.should have_at_least(1).pages
      end
      it "have a name" do
        @source_investigation.name.should_not be_nil
      end

      it "not be changeable by the new author" do
        @source_investigation.should_not be_changeable(@new_author)
      end
    end

    describe "new investigation should" do
      it "exist" do
        @dest_investigation.should_not be_nil
      end

      it "have a similar name" do
        @dest_investigation.name.should match(@source_investigation.name)
        @dest_investigation.name.should match(/copy/i)
      end

      it "not have the same name" do
        @dest_investigation.name.should_not == @source_investigation.name
      end

      it "have a unique id" do
        @dest_investigation.id.should_not be(@source_investigation.id)
      end

      it "be changeable by the new author" do
        @dest_investigation.should be_changeable(@new_author)
        @dest_investigation.should_not be_changeable(@original_author)
      end

      it "have pages which are changable by the new author" do
        @dest_investigation.pages[0].should_not be_nil
        @dest_investigation.pages[0].should be_changeable(@new_author)
        @dest_investigation.pages[0].should_not be_changeable(@original_author)
      end

      it "have an open response which is changeable by the new author" do
        @dest_investigation.pages[0].open_responses[0].should_not be_nil
        @dest_investigation.pages[0].open_responses[0].should be_changeable(@new_author)
        @dest_investigation.pages[0].open_responses[0].should_not be_changeable(@original_author)
      end

      it "have a page_element which is changeable by the new author" do
        @dest_investigation.pages.first.page_elements.first.should_not be_nil
        @dest_investigation.pages.first.page_elements.first.should be_changeable(@new_author)
        @dest_investigation.pages.first.page_elements.first.should_not be_changeable(@original_author)
      end
    end
  end

end
