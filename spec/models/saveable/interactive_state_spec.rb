# frozen_string_literal: false

require 'spec_helper'


RSpec.describe Saveable::InteractiveState, type: :model do



  # TODO: auto-generated
  describe '#answer' do
    it 'answer' do
      interactive_state = described_class.new
      result = interactive_state.answer

      expect(result).to be_nil
    end
  end

  # TODO: auto-generated
  describe '#answer=' do
    it 'answer=' do
      interactive_state = described_class.new
      ans = double('ans')
      result = interactive_state.answer=(ans)

      expect(result).not_to be_nil
    end
  end

end
