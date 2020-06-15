require 'spec_helper'

RSpec.describe FirebaseAppPolicy do
  let (:user) { FactoryBot.create(:user) }
  let (:firebase_app ) { FactoryBot.create(:firebase_app) }
  let (:policy ) { described_class.new(user, firebase_app) }

  describe 'for normal users' do
    it 'index?' do
      expect(policy.index?).to eq false
    end
    it 'new_or_create?' do
      expect(policy.new_or_create?).to eq false
    end
    it 'update_edit_or_destroy?' do
      expect(policy.update_edit_or_destroy?).to eq false
    end
  end

  describe 'for admin users' do
    let (:user) { FactoryBot.generate(:admin_user) }

    it 'index?' do
      expect(policy.index?).to eq true
    end
    it 'new_or_create?' do
      expect(policy.new_or_create?).to eq true
    end
    it 'update_edit_or_destroy?' do
      expect(policy.update_edit_or_destroy?).to eq true
    end
  end
end
