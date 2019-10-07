# frozen_string_literal: false

require 'spec_helper'

RSpec.describe ApplicationController, type: :controller do
  describe '#after_sign_in_path_for' do
    let(:current_user) { FactoryBot.create(:portal_teacher).user }
    before(:each) do
      allow(controller).to receive(:current_user).and_return(current_user)
    end

    it 'runs without error' do
      expect(controller.send(:after_sign_in_path_for, User)).to_not be_nil
    end
  end
end
