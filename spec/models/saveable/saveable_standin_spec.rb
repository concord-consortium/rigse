require File.expand_path('../../../spec_helper', __FILE__)

describe Saveable::SaveableStandin do
  # it_should_behave_like 'a saveable'
  # Not quite -- in this case, there is no embeddable
  before(:each) do
    @nil_standin = Saveable::SaveableStandin.new
    @multiple_choice = Embeddable::MultipleChoice.new
    @real_standin = Saveable::SaveableStandin.new(@multiple_choice)
  end

  it "should resond to embeddable" do
    expect(@nil_standin).to respond_to :embeddable
  end

  it "should respond to submitted?" do
    expect(@nil_standin).to respond_to :submitted?
  end

  it "should optionally return its embeddable" do
    expect(@nil_standin.embeddable).to be_nil
    expect(@real_standin.embeddable).to eq(@multiple_choice)
  end



  # TODO: auto-generated
  describe '#answered?' do
    it 'answered?' do
      _embeddable = double('_embeddable')
      saveable_standin = described_class.new(_embeddable)
      result = saveable_standin.answered?

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#answer' do
    it 'answer' do
      _embeddable = double('_embeddable')
      saveable_standin = described_class.new(_embeddable)
      result = saveable_standin.answer

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#submitted_answer' do
    it 'submitted_answer' do
      _embeddable = double('_embeddable')
      saveable_standin = described_class.new(_embeddable)
      result = saveable_standin.submitted_answer

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#answered_correctly?' do
    it 'answered_correctly?' do
      _embeddable = double('_embeddable')
      saveable_standin = described_class.new(_embeddable)
      result = saveable_standin.answered_correctly?

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#submitted?' do
    it 'submitted?' do
      _embeddable = double('_embeddable')
      saveable_standin = described_class.new(_embeddable)
      result = saveable_standin.submitted?

      expect(result).not_to be_nil
    end
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
  describe '#answers' do
    it 'answers' do
      _embeddable = double('_embeddable')
      saveable_standin = described_class.new(_embeddable)
      result = saveable_standin.answers

      expect(result).not_to be_nil
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
