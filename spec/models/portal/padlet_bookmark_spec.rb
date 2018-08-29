# frozen_string_literal: false

require 'spec_helper'


RSpec.describe Portal::PadletBookmark, type: :model do



  # TODO: auto-generated
  describe '.create_for_user' do
    xit 'create_for_user' do
      user = Factory.create(:user)
      clazz = double('clazz')
      result = described_class.create_for_user(user, clazz)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '.user_can_make?' do
    it 'user_can_make?' do
      user = Factory.create(:user)
      result = described_class.user_can_make?(user)

      expect(result).not_to be_nil
    end
  end

end
