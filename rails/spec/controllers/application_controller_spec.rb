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

    it 'redirects to a path without a host' do
      allow(controller).to receive(:params).and_return({after_sign_in_path: "/somewhere"})
      expect(controller.send(:after_sign_in_path_for, User)).to eq("/somewhere?redirecting_after_sign_in=1")
    end

    it 'does not redirect to other domains' do
      allow(controller).to receive(:params).and_return({after_sign_in_path: "http://evil.domain/somewhere"})
      expect(controller.send(:after_sign_in_path_for, User)).to eq(
        controller.view_context.current_user_home_path)
    end
  end
end
