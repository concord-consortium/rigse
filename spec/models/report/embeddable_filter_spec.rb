require File.expand_path('../../../spec_helper', __FILE__)

describe Report::EmbeddableFilter do
  let(:mc_question_a)  { Embeddable::MultipleChoice.create() }
  let(:mc_question_b)  { Embeddable::MultipleChoice.create() }
  let(:or_question_a)  { Embeddable::OpenResponse.create()   }
  let(:or_question_b)  { Embeddable::OpenResponse.create()   }
  let(:all_embeddables){ [or_question_a, or_question_b, mc_question_a, mc_question_b] }
  let(:mc_questions)   { [mc_question_a, mc_question_b] } 
  let(:embeddables)    { [] }

  subject do 
    filter = Report::EmbeddableFilter.create() 
    filter.embeddables=embeddables
    filter
  end

  describe "#embeddables" do
    let(:embeddables)    { all_embeddables }
    it "should set the instance variable @embeddables_internal" do
      subject.instance_variable_get(:@embeddables_internal).should eq all_embeddables
    end
  end

  describe "#embeddables=" do
    let(:embeddables)    { mc_questions }
    # this is a cheat because our subject is calling #embeddables=
    it "should set the instance variable @embeddables_internal" do
      subject.instance_variable_get(:@embeddables_internal).should eq mc_questions
    end
    it "should set AR attribute embeddables to a serialized hash" do
      hashes = subject.read_attribute(:embeddables)
      hashes.each do |hash| 
        hash.should have_key(:type) 
        hash.should have_key(:id)
      end
    end
  end

  describe "#filter" do
    let(:embeddables) { mc_questions }
    describe "filtering all_embeddables using a mc_questions filter" do  
      it "should only return the multiplechoice embeddables" do
        subject.filter(all_embeddables).should eq mc_questions
      end
    end

    describe "filtering all embeddables using an empty filter" do
      let(:embeddables) { [] }
      it "should return all the embeddables" do
        subject.filter(all_embeddables).should eq all_embeddables
      end
    end
  end

  describe "#clear" do
    let(:embeddables) { all_embeddables }
    before(:each) do
      subject.clear
    end
    it "shouldn't filter anything" do
      subject.instance_variable_get(:@embeddables_internal).should be_nil
    end
    it "serialized embeddables should be empty" do
      subject.read_attribute(:embeddables).should be_empty
    end
  end

end
