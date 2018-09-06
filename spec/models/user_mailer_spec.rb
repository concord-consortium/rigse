# frozen_string_literal: false

require 'spec_helper'


RSpec.describe UserMailer, type: :mailer do


  # TODO: auto-generated
  describe '#confirmation_instructions' do
    it 'confirmation_instructions' do
      user_mailer = described_class
      record = double('record')
      token = double('token')
      opts = {}
      result = user_mailer.confirmation_instructions(record, token, opts)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#activation' do
    it 'activation' do
      user_mailer = described_class
      user = Factory.create(:user)
      result = user_mailer.activation(user)

      expect(result).not_to be_nil
    end
  end

end
