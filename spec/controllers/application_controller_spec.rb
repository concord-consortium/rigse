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

    context 'the session contains oauth_authorize_params' do
      let(:session) { {oauth_authorize_params: {} } }
      before(:each) do
        allow(controller).to receive(:session).and_return(session)
        allow(AccessGrant).to receive(:get_authorize_redirect_uri).and_return('blah')
      end

      it 'runs without error' do
        expect(controller.send(:after_sign_in_path_for, User)).to eq('blah')
      end

      context 'the Auth Client is invalid and raises an error' do
        before(:each) do
          allow(AccessGrant).to receive(:get_authorize_redirect_uri).and_raise('invalid')
        end

        it 'resets the session and re raises the exception' do
          expect(controller).to receive(:reset_session)
          expect { controller.send(:after_sign_in_path_for, User) }.to raise_error('invalid')
        end
      end
    end
  end
end
