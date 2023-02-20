require File.expand_path('../../../spec_helper', __FILE__)

describe Saveable::OpenResponse do
  # TODO: auto-generated
  describe '#answered?' do
    it 'answered?' do
      open_response = described_class.new
      result = open_response.answered?

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#embeddable' do
    it 'embeddable' do
      open_response = described_class.new
      result = open_response.embeddable

      expect(result).to be_nil
    end
  end

  # TODO: auto-generated
  describe '#submitted_answer' do
    it 'submitted_answer' do
      open_response = described_class.new
      result = open_response.submitted_answer

      expect(result).not_to be_nil
    end
  end


end
