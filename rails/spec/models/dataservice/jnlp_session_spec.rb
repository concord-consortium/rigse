# frozen_string_literal: false

require 'spec_helper'


RSpec.describe Dataservice::JnlpSession, type: :model do


  # TODO: auto-generated
  describe '#create_token' do
    it 'create_token' do
      jnlp_session = described_class.new
      result = jnlp_session.create_token

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#access_user' do
    it 'access_user' do
      jnlp_session = described_class.new
      result = jnlp_session.access_user

      expect(result).to be_nil
    end
  end

  # TODO: auto-generated
  describe '.get_user_from_token' do
    it 'get_user_from_token' do
      token = 'token'
      result = described_class.get_user_from_token(token)

      expect(result).to be_nil
    end
  end

end
