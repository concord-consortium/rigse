# frozen_string_literal: false

require 'spec_helper'

RSpec.describe Password, type: :model do
  let(:user) {FactoryGirl.create(:user)}
  let(:password) {Password.new(user: user)}

  describe '#initialize_reset_code_and_expiration' do
    it 'does not create with missing email' do
      expect(password).not_to be_valid
    end

    it 'does not create with improper email' do
      password.email = 'abcexample.com'
      expect(password).not_to be_valid
    end

    it 'does  create with proper email' do
      password.email = 'abc@example.com'
      expect(password).to be_valid

      password.save!

      expect(password.reset_code).not_to be_empty
      expect(password.expiration_date).to be > 13.days.from_now
    end
  end
end
