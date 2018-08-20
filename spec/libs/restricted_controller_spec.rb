# frozen_string_literal: false

require 'spec_helper'

RSpec.xdescribe RestrictedController do


  # TODO: auto-generated
  describe '#manager' do
    it 'manager' do
      restricted_controller = described_class.new
      result = restricted_controller.manager

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#manager_or_researcher' do
    it 'manager_or_researcher' do
      restricted_controller = described_class.new
      result = restricted_controller.manager_or_researcher

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#admin_only' do
    it 'admin_only' do
      restricted_controller = described_class.new
      result = restricted_controller.admin_only

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#admin_or_config' do
    it 'admin_or_config' do
      restricted_controller = described_class.new
      result = restricted_controller.admin_or_config

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#require_roles' do
    it 'require_roles' do
      restricted_controller = described_class.new
      roles = double('roles')
      result = restricted_controller.require_roles(*roles)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#force_signin' do
    it 'force_signin' do
      restricted_controller = described_class.new
      result = restricted_controller.force_signin

      expect(result).not_to be_nil
    end
  end

end
