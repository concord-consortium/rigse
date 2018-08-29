# frozen_string_literal: false

require 'spec_helper'

RSpec.describe Publishable do

  # TODO: auto-generated
  describe '#available_states' do
    xit 'available_states' do
      publishable = described_class
      who_wants_to_know = User.new
      result = publishable.available_states(who_wants_to_know)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#public?' do
    xit 'public?' do
      publishable = described_class
      result = publishable.public?

      expect(result).not_to be_nil
    end
  end

end
