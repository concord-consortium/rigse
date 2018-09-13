# frozen_string_literal: false

require 'spec_helper'

RSpec.describe Reports::Account do

  # TODO: auto-generated
  describe '#school_name' do
    it 'school_name' do
      opts = {}
      account = described_class.new(opts)
      result = account.school_name(User.new)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#class_name' do
    xit 'class_name' do
      opts = {}
      account = described_class.new(opts)
      clazz = double('clazz')
      result = account.class_name(clazz)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#process_portal_user' do
    xit 'process_portal_user' do
      opts = {}
      account = described_class.new(opts)
      user = FactoryGirl.create(:user)
      portal_user = double('portal_user')
      user_type = double('user_type')
      sheet = double('sheet')
      result = account.process_portal_user(user, portal_user, user_type, sheet)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#run_report' do
    it 'run_report' do
      opts = {}
      account = described_class.new(opts)
      result = account.run_report

      expect(result).not_to be_nil
    end
  end

end
