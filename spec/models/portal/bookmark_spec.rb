# frozen_string_literal: false

require 'spec_helper'


RSpec.describe Portal::Bookmark, type: :model do

  let(:user) { FactoryGirl.create(:user) }

  # TODO: auto-generated
  describe '.available_types' do
    it 'available_types' do
      result = described_class.available_types

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '.for_project' do
    it 'for_project' do
      result = described_class.for_project

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '.for_user' do
    it 'for_user' do
      result = described_class.for_user(user)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '.enabled_bookmark_types' do
    it 'enabled_bookmark_types' do
      result = described_class.enabled_bookmark_types

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '.allowed_types' do
    it 'allowed_types' do
      result = described_class.allowed_types

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '.is_allowed?' do
    it 'is_allowed?' do
      result = described_class.is_allowed?

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '.user_can_make?' do
    it 'user_can_make?' do
      result = described_class.user_can_make?(user)

      expect(result).to be_nil
    end
  end

  # TODO: auto-generated
  describe '#url=' do
    it 'url=' do
      bookmark = described_class.new
      url = 'url'
      result = bookmark.url=(url)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#visits' do
    it 'visits' do
      bookmark = described_class.new
      result = bookmark.visits

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#record_visit' do
    it 'record_visit' do
      bookmark = described_class.new
      result = bookmark.record_visit(user)

      expect(result).not_to be_nil
    end
  end

end
