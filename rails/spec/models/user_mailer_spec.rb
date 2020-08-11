# frozen_string_literal: false

require 'spec_helper'


RSpec.describe UserMailer, type: :mailer do


  # TODO: auto-generated
  describe '#confirmation_instructions' do
    it 'confirmation_instructions' do
      user_mailer = described_class
      record = Factory.create(:user)
      token = double('token')
      opts = {}
      result = user_mailer.confirmation_instructions(record, token, opts)
      expect(result).not_to be_nil
    end
  end

end
