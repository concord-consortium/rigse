# encoding: utf-8
require 'spec_helper'

describe API::V1::UserRegistration do
  it_behaves_like 'user registration'



  # TODO: auto-generated
  describe '#login=' do
    it 'login=' do
      user_registration = described_class.new
      _login = double('_login')
      result = user_registration.login=(_login)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#set_user' do
    it 'set_user' do
      user_registration = described_class.new
      user = Factory.create(:user)
      result = user_registration.set_user(user)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#set_defaults' do
    it 'set_defaults' do
      user_registration = described_class.new
      result = user_registration.set_defaults

      expect(result).to be_nil
    end
  end

  # TODO: auto-generated
  describe '#password_confirmation' do
    it 'password_confirmation' do
      user_registration = described_class.new
      result = user_registration.password_confirmation

      expect(result).to be_nil
    end
  end

  # TODO: auto-generated
  describe '#user_params' do
    it 'user_params' do
      user_registration = described_class.new
      result = user_registration.user_params

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#new_user' do
    it 'new_user' do
      user_registration = described_class.new
      result = user_registration.new_user

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#user_is_valid' do
    it 'user_is_valid' do
      user_registration = described_class.new
      result = user_registration.user_is_valid

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#save' do
    it 'save' do
      user_registration = described_class.new
      result = user_registration.save

      expect(result).not_to be_nil
    end
  end


end
