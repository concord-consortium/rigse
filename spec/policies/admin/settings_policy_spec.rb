# frozen_string_literal: false

require 'spec_helper'

RSpec.describe Admin::SettingsPolicy do
  let (:user) { FactoryBot.create(:user) }
  let (:admin_settings ) { FactoryBot.create(:admin_settings) }
  let (:policy ) { described_class.new(user, admin_settings) }

  describe "Scope" do
    context 'for normal users' do
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

    context 'for admin users' do
      let(:user) { FactoryBot.generate(:admin_user) }
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
end
