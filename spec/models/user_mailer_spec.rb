# frozen_string_literal: false

require 'spec_helper'


RSpec.describe UserMailer, type: :mailer do


  # TODO: auto-generated
  describe '#confirmation_instructions' do
    it 'confirmation_instructions' do
      user_mailer = described_class
      record = double('record')
      opts = {}
      result = user_mailer.confirmation_instructions(record, opts)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#signup_notification' do
    it 'signup_notification' do
      user_mailer = described_class
      user = FactoryGirl.create(:user)
      result = user_mailer.signup_notification(user)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#activation' do
    it 'activation' do
      user_mailer = described_class
      user = FactoryGirl.create(:user)
      result = user_mailer.activation(user)

      expect(result).not_to be_nil
    end
  end

end
