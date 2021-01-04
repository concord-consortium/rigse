require File.expand_path('../../../spec_helper', __FILE__)

describe Saveable::MultipleChoice do

  it_should_behave_like 'a saveable'



  # TODO: auto-generated
  describe '#answered?' do
    it 'answered?' do
      multiple_choice = described_class.new
      result = multiple_choice.answered?

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#embeddable' do
    it 'embeddable' do
      multiple_choice = described_class.new
      result = multiple_choice.embeddable

      expect(result).to be_nil
    end
  end

  # TODO: auto-generated
  describe '#answer' do
    it 'answer' do
      multiple_choice = described_class.new
      result = multiple_choice.answer

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#submitted_answer' do
    it 'submitted_answer' do
      multiple_choice = described_class.new
      result = multiple_choice.submitted_answer

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#answered_correctly?' do
    it 'answered_correctly?' do
      multiple_choice = described_class.new
      result = multiple_choice.answered_correctly?

      expect(result).not_to be_nil
    end
  end


end
