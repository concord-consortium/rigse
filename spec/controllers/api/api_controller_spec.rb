# frozen_string_literal: false

require 'spec_helper'

RSpec.describe API::APIController, type: :controller do

  describe '#show' do
    it 'GET show' do
      expect { get :show, {}, {} }.to raise_error(Pundit::NotDefinedError)
    end
  end

  describe '#create' do
    it 'POST create' do
      expect { post :create, {}, {} }.to raise_error(Pundit::NotDefinedError)
    end
  end

  describe '#update' do
    it 'PATCH update' do
      expect { put :update, {}, {} }.to raise_error(Pundit::NotDefinedError)
    end
  end

  describe '#index' do
    it 'GET index' do
      expect { get :index, {}, {} }.to raise_error(Pundit::NotDefinedError)
    end
  end

  describe '#destroy' do
    it 'DELETE destroy' do
      expect { delete :destroy, {}, {} }.to raise_error(Pundit::NotDefinedError)
    end
  end
end
