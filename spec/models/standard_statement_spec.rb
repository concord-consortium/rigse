require 'spec_helper'

describe StandardStatement do

  subject { StandardStatement.create(attributes) }

  describe "create" do

    context "with description array" do
      let(:attributes) do 
        {
          uri: "http://asn.jesandco.org/resources/S2454349", 
          doc: "NGSS", 
          statement_notation: "TEST-K-PS2", 
          statement_label: "Disciplinary Core Idea", 
          description: [ "Motion and Stability", "Forces and Interactions" ],
          material_type: "external_activity", 
          material_id: 1 
        }
      end
      it "should save and load description array" do
        subject2 = StandardStatement.find_by_id(subject.id)
        expect(subject2.description.size).to eq 2
      end
    end

    context "with parents" do
      let(:attributes) do 
        {
          uri: "http://asn.jesandco.org/resources/S2454349", 
          doc: "NGSS", 
          statement_notation: "TEST-K-PS2", 
          statement_label: "Disciplinary Core Idea", 
          description: [ "Motion and Stability", "Forces and Interactions" ],
          material_type: "external_activity", 
          material_id: 1,
          parents:  [
                        {   description: "parent", 
                            uri: "http://foo.com/ID123",
                            notation: "A-1" },

                        {   description: "grandparent", 
                            uri: "http://foo.com/ID456",
                            notation: "B-2" }
                    ]
        }
      end
      it "should save and load parent" do
        subject2 = StandardStatement.find_by_id(subject.id)
        expect(subject2.parents[0][:uri]).to eq "http://foo.com/ID123"
        expect(subject2.parents[0][:notation]).to eq "A-1"
        expect(subject2.parents[1][:uri]).to eq "http://foo.com/ID456"
        expect(subject2.parents[1][:notation]).to eq "B-2"
      end
    end
  end


  # TODO: auto-generated
  describe '#duplicate_and_assign_to' do
    it 'duplicate_and_assign_to' do
      standard_statement = described_class.new
      material_type = 'material_type'
      material_id = 1
      result = standard_statement.duplicate_and_assign_to(material_type, material_id)

      expect(result).not_to be_nil
    end
  end


end
