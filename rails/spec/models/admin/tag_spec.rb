# frozen_string_literal: false

require 'spec_helper'

RSpec.describe Admin::Tag, type: :model do
  let(:valid_attributes) do
    {
      scope: 'value for scope',
      tag: 'value for tag'
    }
  end
  let(:bad_attributes) do
    {
      scope: 'no blank tags',
      tag: ''
    }
  end

  it 'should create a new instance given valid attributes' do
    Admin::Tag.create!(valid_attributes)
  end

  it 'should not create a new instance given bad attributes' do
    expect(Admin::Tag.create(bad_attributes)).not_to be_valid
  end

  # TODO: auto-generated
  describe '.searchable_attributes' do
    it 'searchable_attributes' do
      result = described_class.searchable_attributes

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '.search' do
    it 'search' do
      options = {}
      result = described_class.search(options, 1, nil)
      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '.fetch_tag' do
    it 'fetch_tag' do
      options = {}
      result = described_class.fetch_tag(options)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '.add_new_admin_tags' do
    xit 'add_new_admin_tags' do
      taggable = double('taggable')
      tag_type = double('tag_type')
      tag_list = double('tag_list')
      result = described_class.add_new_admin_tags(taggable, tag_type, tag_list)
      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#name' do
    it 'name' do
      tag = described_class.new
      result = tag.name

      expect(result).not_to be_nil
    end
  end

end
