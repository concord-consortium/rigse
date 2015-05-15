require 'spec_helper'

describe MaterialsCollection do
  let(:collection) { FactoryGirl.create(:materials_collection) }
  let(:ext_act) { FactoryGirl.create_list(:external_activity, 3) }
  let(:act) { FactoryGirl.create_list(:activity, 3) }
  let(:inv) { FactoryGirl.create_list(:investigation, 3) }
  let(:materials) { ext_act + act + inv }

  before(:each) do
    # Assign some materials to cohorts.
    materials.each_with_index do |m, i|
      m.cohort_list = ["foo"] if i % 3 === 0
      m.cohort_list = ["bar"] if i % 3 === 1
      m.save!
    end
    # Assign all materials to collection.
    materials.each do |m|
      FactoryGirl.create(:materials_collection_item, material: m, materials_collection: collection)
    end
  end

  describe "#materials" do
    context "when no argument is provided" do
      it "should return all materials" do
        expect(collection.materials).to eql(materials)
      end
    end

    context "when cohorts list is provided" do
      it "should return only materials that are assigned to the same cohort or not assigned to any cohort" do
        expect(collection.materials(["foo"])).to eql(materials.select { |m| m.cohort_list.empty? || m.cohort_list.include?("foo") })
        expect(collection.materials(["bar"])).to eql(materials.select { |m| m.cohort_list.empty? || m.cohort_list.include?("bar") })
        expect(collection.materials(["foo", "bar"])).to eql(materials.select { |m| m.cohort_list.empty? || m.cohort_list.include?("foo") ||  m.cohort_list.include?("bar") })
        expect(collection.materials(["nonexistent-cohort"])).to eql(materials.select { |m| m.cohort_list.empty? })
      end
    end
  end
end
