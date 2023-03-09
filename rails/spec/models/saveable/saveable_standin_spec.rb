require File.expand_path('../../../spec_helper', __FILE__)

describe Saveable::SaveableStandin do
  # Not quite -- in this case, there is no embeddable
  before(:each) do
    @nil_standin = Saveable::SaveableStandin.new
    @multiple_choice = Embeddable::MultipleChoice.new
    @real_standin = Saveable::SaveableStandin.new(@multiple_choice)
  end

  it "should resond to embeddable" do
    expect(@nil_standin).to respond_to :embeddable
  end

  it "should optionally return its embeddable" do
    expect(@nil_standin.embeddable).to be_nil
    expect(@real_standin.embeddable).to eq(@multiple_choice)
  end

  # TODO: auto-generated
  describe '#current_feedback' do
    it 'current_feedback' do
      _embeddable = double('_embeddable')
      saveable_standin = described_class.new(_embeddable)
      result = saveable_standin.current_feedback

      expect(result).to be_nil
    end
  end

  # TODO: auto-generated
  describe '#score' do
    it 'score' do
      _embeddable = double('_embeddable')
      saveable_standin = described_class.new(_embeddable)
      result = saveable_standin.score

      expect(result).to be_nil
    end
  end

  # TODO: auto-generated
  describe '#has_been_reviewed' do
    it 'has_been_reviewed' do
      _embeddable = double('_embeddable')
      saveable_standin = described_class.new(_embeddable)
      result = saveable_standin.has_been_reviewed

      expect(result).not_to be_nil
    end
  end


end
