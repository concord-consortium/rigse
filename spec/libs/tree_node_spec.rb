# frozen_string_literal: false

require 'spec_helper'

RSpec.describe TreeNode do

  let(:tree_node) { Activity.new }
  # TODO: auto-generated
  describe '#child_after' do
    it 'child_after' do
      
      child = double('child')
      result = tree_node.child_after(child)

      expect(result).to be_nil
    end
  end

  # TODO: auto-generated
  describe '#child_before' do
    it 'child_before' do
      
      child = double('child')
      result = tree_node.child_before(child)

      expect(result).to be_nil
    end
  end

  # TODO: auto-generated
  describe '#next' do
    it 'next' do
      
      result = tree_node.next

      expect(result).to be_nil
    end
  end

  # TODO: auto-generated
  describe '#previous' do
    it 'previous' do
      
      result = tree_node.previous

      expect(result).to be_nil
    end
  end

  # TODO: auto-generated
  describe '#number' do
    it 'number' do
      
      result = tree_node.number

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#each' do
    it 'each' do
      result = tree_node.each {}

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#deep_set_user' do
    it 'deep_set_user' do
      
      new_user = User.new
      logging = double('logging')
      result = tree_node.deep_set_user(new_user, logging)

      expect(result).to be_nil
    end
  end

end
