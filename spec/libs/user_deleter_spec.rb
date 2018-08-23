# frozen_string_literal: false

require 'spec_helper'

RSpec.describe UserDeleter do

  # TODO: auto-generated
  describe '#delete_all' do
    it 'delete_all' do
      options = {}
      user_deleter = described_class.new(options)
      result = user_deleter.delete_all

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#delete_user_list' do
    xit 'delete_user_list' do
      options = {}
      user_deleter = described_class.new(options)
      user_list = double('user_list')
      conditions = double('conditions')
      result = user_deleter.delete_user_list(user_list, conditions)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#reown_investigations' do
    xit 'reown_investigations' do
      options = double('options')
      user_deleter = described_class.new(options)
      user = double('user')
      result = user_deleter.reown_investigations(user)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#delete_user' do
    xit 'delete_user' do
      options = double('options')
      user_deleter = described_class.new(options)
      user = double('user')
      result = user_deleter.delete_user(user)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#delete_student' do
    it 'delete_student' do
      options = double('options')
      user_deleter = described_class.new(options)
      user = Factory.create(:user)
      result = user_deleter.delete_student(user)

      expect(result).to be_nil
    end
  end

  # TODO: auto-generated
  describe '#delete_clazzes' do
    it 'delete_clazzes' do
      options = double('options')
      user_deleter = described_class.new(options)
      user = Factory.create(:user)
      result = user_deleter.delete_clazzes(user)

      expect(result).to be_nil
    end
  end

end
