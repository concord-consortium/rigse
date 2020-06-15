# frozen_string_literal: false

require 'spec_helper'

RSpec.describe PasswordMailer, type: :mailer do

  # TODO: auto-generated
  describe '#forgot_password' do
    xit 'forgot_password' do
      password_mailer = described_class
      password = ('password')
      result = password_mailer.forgot_password(password)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#reset_password' do
    it 'reset_password' do
      password_mailer = described_class
      user = FactoryBot.create(:user)
      result = password_mailer.reset_password(user)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#imported_password_reset' do
    xit 'imported_password_reset' do
      password_mailer = described_class
      password = ('password')
      result = password_mailer.imported_password_reset(password)

      expect(result).not_to be_nil
    end
  end

end
