require 'spec_helper'

describe MaterialsCollection do
  let(:foo_cohort) { FactoryBot.create(:admin_cohort, name: 'foo') }
  let(:bar_cohort) { FactoryBot.create(:admin_cohort, name: 'bar') }
  let(:nonexistent_cohort) { FactoryBot.create(:admin_cohort, name: 'nonexistent-cohort') }

  let(:collection) { FactoryBot.create(:materials_collection) }
  let(:ext_act) { FactoryBot.create_list(:external_activity, 3) }
  let(:materials) { ext_act }

  before(:each) do
    # Assign all materials to collection.
    materials.each do |m|
      FactoryBot.create(:materials_collection_item, material: m, materials_collection: collection)
    end
  end

  describe "#materials" do
    context "when no argument is provided" do
      it "should return all materials" do
        expect(collection.materials).to eql(materials)
      end
    end

    context "when cohorts list is provided" do
      before(:each) do
        # Assign some materials to cohorts.
        materials.each_with_index do |m, i|
          m.cohorts = [foo_cohort] if i % 3 === 0
          m.cohorts = [bar_cohort] if i % 3 === 1
          m.save!
        end
      end
      it "should return only materials that are assigned to the same cohort or not assigned to any cohort" do
        expect(collection.materials([foo_cohort])).to eql(materials.select { |m| m.cohorts.empty? || m.cohorts.include?(foo_cohort) })
        expect(collection.materials([bar_cohort])).to eql(materials.select { |m| m.cohorts.empty? || m.cohorts.include?(bar_cohort) })
        expect(collection.materials([foo_cohort, bar_cohort])).to eql(materials.select { |m| m.cohorts.empty? || m.cohorts.include?(foo_cohort) ||  m.cohorts.include?(bar_cohort) })
        expect(collection.materials([nonexistent_cohort])).to eql(materials.select { |m| m.cohorts.empty? })
      end
    end

    context "show_assessment_items argument" do
      before(:each) do
        # Mark some materials as assessment items.
        materials.each_with_index do |m, i|
          m.is_assessment_item = true if i % 2 === 0
          m.save!
        end
      end
      context "when it's false" do
        it "should return only materials that are not marked as assessment items" do
          expect(collection.materials(nil, false)).to eql(materials.select { |m| !m.is_assessment_item })
          expect(collection.materials(nil, false).length).to eql(materials.length / 2)
        end
      end
      context "when it's true" do
        it "should return all the materials: non-assessment and assessment items" do
          expect(collection.materials(nil, true)).to eql(materials)
          expect(collection.materials(nil, true).length).to eql(materials.length)
        end
      end
    end
  end

  # TODO: auto-generated
  describe '.searchable_attributes' do
    it 'searchable_attributes' do
      result = described_class.searchable_attributes

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#materials' do
    it 'materials' do
      materials_collection = described_class.new
      result = materials_collection.materials([])

      expect(result).not_to be_nil
    end
  end


end
