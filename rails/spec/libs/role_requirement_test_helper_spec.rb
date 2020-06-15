# frozen_string_literal: false

require 'spec_helper'

RSpec.xdescribe RoleRequirementTestHelper do

  # TODO: auto-generated
  describe '#assert_user_can_access' do
    it 'assert_user_can_access' do
      role_requirement_test_helper = described_class.new
      user = double('user')
      actions = double('actions')
      params = double('params')
      result = role_requirement_test_helper.assert_user_can_access(user, actions, params)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#assert_user_cant_access' do
    it 'assert_user_cant_access' do
      role_requirement_test_helper = described_class.new
      user = double('user')
      actions = double('actions')
      params = double('params')
      result = role_requirement_test_helper.assert_user_cant_access(user, actions, params)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#assert_users_access' do
    it 'assert_users_access' do
      role_requirement_test_helper = described_class.new
      users_access_list = double('users_access_list')
      actions = double('actions')
      params = double('params')
      result = role_requirement_test_helper.assert_users_access(users_access_list, actions, params)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#assert_user_cannot_access' do
    it 'assert_user_cannot_access' do
      role_requirement_test_helper = described_class.new
      user = double('user')
      actions = double('actions')
      params = double('params')
      result = role_requirement_test_helper.assert_user_cannot_access(user, actions, params)

      expect(result).not_to be_nil
    end
  end

end
