require 'spec_helper'

describe MaterialsCollection do
  let(:foo_cohort) { FactoryGirl.create(:admin_cohort, name: 'foo') }
  let(:bar_cohort) { FactoryGirl.create(:admin_cohort, name: 'bar') }
  let(:nonexistent_cohort) { FactoryGirl.create(:admin_cohort, name: 'nonexistent-cohort') }

  let(:collection) { FactoryGirl.create(:materials_collection) }

  # Assign some materials to cohorts.
  let(:materials) { [
      FactoryGirl.create(:external_activity, cohorts: [foo_cohort]),
      FactoryGirl.create(:external_activity, cohorts: [bar_cohort]),
      FactoryGirl.create(:external_activity, cohorts: [foo_cohort, bar_cohort]),
      FactoryGirl.create(:external_activity),
      FactoryGirl.create(:activity, cohorts: [foo_cohort]),
      FactoryGirl.create(:activity, cohorts: [bar_cohort]),
      FactoryGirl.create(:activity, cohorts: [foo_cohort, bar_cohort]),
      FactoryGirl.create(:activity),
      FactoryGirl.create(:investigation, cohorts: [foo_cohort]),
      FactoryGirl.create(:investigation, cohorts: [bar_cohort]),
      FactoryGirl.create(:investigation, cohorts: [foo_cohort, bar_cohort]),
      FactoryGirl.create(:investigation)
    ] }

  before(:each) do
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
      context "and the cohort list is empty" do
        it "should only return materials not assigned to a cohort" do
          expect(collection.materials([])).to eql(materials.select { |m| m.cohorts.empty? })
        end
      end

      context "and the cohort list is a single cohort not assigned to any manterials" do
        it "should only return materials not assigned to any cohort" do
          expect(collection.materials([nonexistent_cohort])).to eql(materials.select { |m| m.cohorts.empty? })
        end
      end

      context "and the cohort list contains a cohort assigned to some materials" do
        it "should return materials with the matching cohort and materials with no cohort" do
          expect(collection.materials([foo_cohort])).to eql(materials.select { |m|
            m.cohorts.empty? || m.cohorts.include?(foo_cohort) })
          expect(collection.materials([bar_cohort])).to eql(materials.select { |m|
            m.cohorts.empty? || m.cohorts.include?(bar_cohort) })
        end
      end

      context "and the chort list contains two cohorts each assigned to some materials" do
        it "should return materials that have either cohort and materials with no cohort" do
          expect(collection.materials([foo_cohort, bar_cohort])).to eql(materials.select { |m|
            m.cohorts.empty? || m.cohorts.include?(foo_cohort) ||  m.cohorts.include?(bar_cohort) })
        end
      end
    end
  end
end
