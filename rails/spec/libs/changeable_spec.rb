# frozen_string_literal: false

require 'spec_helper'

RSpec.describe Changeable do

  let(:object) { FactoryBot.create(:activity) }
  
  # TODO: auto-generated
  describe '#changeable?' do
    it 'changeable?' do
      changeable = object
      user = FactoryBot.create(:user)
      result = changeable.changeable?(user)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#owned?' do
    it 'owned?' do
      changeable = object
      result = changeable.owned?

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#un_owned?' do
    it 'un_owned?' do
      changeable = object
      result = changeable.un_owned?

      expect(result).not_to be_nil
    end
  end

end
