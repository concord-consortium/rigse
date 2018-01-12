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
        subject2.description.size.should eq 2
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
        subject2.parents[0][:uri].should eq "http://foo.com/ID123"
        subject2.parents[0][:notation].should eq "A-1"
        subject2.parents[1][:uri].should eq "http://foo.com/ID456"
        subject2.parents[1][:notation].should eq "B-2"
      end
    end


  end


end
