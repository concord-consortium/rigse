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
      {
        id: "google",
        label: "google",
        sort: 5,
        url: "http://google.com"
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
      expect(nav_service.sections.size).to eq(4)
    end
    it "should have 2 links" do
      expect(nav_service.links.size).to eq(3)
    end
  end

  describe "nested structure" do
    describe "schema validation" do
      subject { nav_service.to_json }
      it { is_expected.to match_response_schema("navigation")}
    end
    describe "values" do
      let(:greeting) { "bonjour" }
      subject { nav_service.to_hash }
      it { is_expected.to include(name:  name )}
      it { is_expected.to include(greeting: "bonjour") }
      it { is_expected.to include(:help) }
      it { is_expected.to include(:links) }
      it { is_expected.not_to include("xxx") }
      describe "nested links" do
        it "should have /classes/2/assign link" do
          expect(subject[:links].first()[:children].first()[:children].first()[:id]).to eq("/classes/2/assign")
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
          expect(subject[:links].first()[:children].first()[:children].first()[:id]).to eq("/classes/2/roster")
        end
      end
      describe "with roster using higher sort value" do
        let(:sort) { 7 }
        it "should have /classes/2/assign should appear before /casses/2/roster" do
          expect(subject[:links].first()[:children].first()[:children].first()[:id]).to eq("/classes/2/assign")
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
            expect(gather_item_values(subject[:links], :id)).to include("/resources")
            expect(gather_item_values(subject[:links], :id)).to include("/classes")
          end
        end

        describe "supressing the resources section" do
          let(:supress_path) { "/resources" }
          it "should no longer have a resources section" do
            expect(gather_item_values(subject[:links], :id)).not_to include("/resources")
          end
        end
      end

    end
  end

  # TODO: auto-generated
  describe '#defaults' do
    xit 'defaults' do
      props = {}
      nav_item = described_class.new(props)
      result = nav_item.defaults

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#merge' do
    xit 'merge' do
      props = {}
      nav_item = described_class.new(props)
      result = nav_item.merge({})

      expect(result).not_to be_nil
    end
  end

end
