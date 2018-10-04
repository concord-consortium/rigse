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
      @original_author = FactoryBot.create(:user)
      @new_author = FactoryBot.create(:user)
      @source_investigation = FactoryBot.create(:investigation, :user => @original_author)
      @source_investigation.activities << FactoryBot.create(:activity, :user => @original_author)
      @source_investigation.activities[0].sections << FactoryBot.create(:section, :user => @original_author)
      @source_investigation.activities[0].sections[0].pages << FactoryBot.create(:page, :user => @original_author)

      open_response = FactoryBot.create(:open_response, :user => @original_author)
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

    end
  end

end
