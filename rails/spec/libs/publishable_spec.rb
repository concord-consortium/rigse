# frozen_string_literal: false

require 'spec_helper'

class DummyClass
  def self.aasm_column(symbol) end
  def self.scope(name, lambda) end
  include Publishable
  attr_accessor :publication_status
  def initialize
    self.publication_status = :draft
  end
end

RSpec.describe Publishable do
  let(:user_has_roles) { false }
  let(:user) { mock_model(User, {has_role?: user_has_roles}) }
  let(:instance) { DummyClass.new }

  describe '#available_states' do
    describe 'when a non-admin is asking:' do
      let(:user_has_roles) { false }
      it 'should display all states besides public' do
        result = instance.available_states(user)

        expect(result).to include(:draft, :private)
        expect(result).not_to include(:published)
      end
    end
    describe 'when aa admin is asking:' do
      let(:user_has_roles) { true }
      it 'should display all states' do
        result = instance.available_states(user)
        expect(result).to include(:draft, :private, :published)
      end
    end
  end

  describe '#public?' do
    describe 'intial state' do
      it 'should be false' do
        expect(instance.public?).to eql false
      end
    end

    describe 'when published' do
      it 'should be true' do
        instance.publication_status = 'published'
        expect(instance.public?).to eql true
      end
    end

    describe 'when unpublished' do
      it 'should be published' do
        instance.publication_status = 'private'
        expect(instance.public?).to eql false
      end
    end
  end

  describe '#publish!' do
    it 'should update publication_status' do
      instance.publication_status = 'private'
      instance.publish!
      expect(instance.publication_status).to eql 'published'
    end
    it 'should change result of #public? to true' do
      instance.publication_status = 'private'
      instance.publish!
      expect(instance.public?).to eql true
    end
  end

  describe '#un_publish!' do
    it 'should set publication_status to draft' do
      instance.publication_status = 'published'
      instance.un_publish!
      expect(instance.publication_status).to eql 'draft'
    end
    it 'should change result of #public? to false' do
      instance.publication_status = 'published'
      instance.un_publish!
      expect(instance.public?).to eql false
    end
  end

end
