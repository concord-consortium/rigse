require 'spec_helper'

def gather_item_values(obj,key)
  results = []
  if obj.respond_to?(:key?) && obj.key?(key)
    results.push obj[key]
  elsif obj.respond_to?(:each)
    obj.select { |*a| results.push gather_item_values(a.last,key) }
  end
  results.flatten
end

describe NavigationService do
  let(:name)     { "Mad Franky" }
  let(:greeting) { "Hello"}
  let(:items) {
    [
      {
        id: "/classes/2",
        label: "Noahs Class",
        type: NavigationService::SECTION_TYPE,
        sort: 1,
      },
      {
        id: "/classes/2/assign",
        label: "Assign Material",
        sort: 1,
        url: "/classes/2/edit"
      },
      {
        id: "/resources/schoology",
        label: "schoology",
        sort: 1,
        url: "http://scologoy.com"
      },
    ]
  }
  let(:params) {
    {
      greeting: greeting,
      name: name
    }
  }
  let(:nav_service) { NavigationService.new(nil,params) }

  before(:each) do
    nav_service
    items.each { |item| nav_service.add_item(item) }
  end

  describe "basics" do
    it "should have some sections" do
      nav_service.sections.should have(4).sections
    end
    it "should have 2 links" do
      nav_service.links.should have(2).links
    end
  end

  describe "nested structure" do
    describe "schema validation" do
      subject { nav_service.to_json }
      it { should match_response_schema("navigation")}
    end
    describe "values" do
      let(:greeting) { "bonjour" }
      subject { nav_service.to_hash }
      it { should include(name:  name )}
      it { should include(greeting: "bonjour") }
      it { should include(:help) }
      it { should include(:links) }
      it { should_not include("xxx") }
      describe "nested links" do
        it "should have /classes/2/assign link" do
          subject[:links].first()[:children].first()[:children].first()[:id].should eq("/classes/2/assign")
        end
      end
    end
  end
  describe "sort orders" do
    let(:sort)     { 5 }
    let(:new_item) {
      {
        id: "/classes/2/roster",
        label: "Class Roster",
        sort: sort,
        url: "/classes/2/roster"
      }
    }
    subject { nav_service.to_hash }
    before(:each) do
      nav_service.add_item(new_item)
    end
    describe "nested links" do
      describe "with roster using lower sort value" do
        let(:sort) { 0 }
        it "should have /classes/2/assign should appear after /casses/2/roster" do
          subject[:links].first()[:children].first()[:children].first()[:id].should eq("/classes/2/roster")
        end
      end
      describe "with roster using higher sort value" do
        let(:sort) { 7 }
        it "should have /classes/2/assign should appear before /casses/2/roster" do
          subject[:links].first()[:children].first()[:children].first()[:id].should eq("/classes/2/assign")
        end
      end
      describe "supressing items" do
        let(:supress_path) { "/foo" }
        before(:each) do
          nav_service.remove_item(supress_path)
        end
        describe "supressing a non existant item" do
          let(:supress_path) { "/foo" }
          it "it should still have all sections, such as resources and classes" do
            gather_item_values(subject[:links], :id).should include("/resources")
            gather_item_values(subject[:links], :id).should include("/classes")
          end
        end

        describe "supressing the resources section" do
          let(:supress_path) { "/resources" }
          it "should no longer have a resources section" do
            gather_item_values(subject[:links], :id).should_not include("/resources")
          end
        end
      end

    end
  end
end
