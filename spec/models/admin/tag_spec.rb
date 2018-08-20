# frozen_string_literal: false

require 'spec_helper'


RSpec.describe Admin::Tag, type: :model do
  before(:each) do
    @valid_attributes = {
        :scope => "value for scope",
        :tag => "value for tag"
    }
  end

  it "should create a new instance given valid attributes" do
    Admin::Tag.create!(@valid_attributes)
  end


  # TODO: auto-generated
  describe '.searchable_attributes' do
    it 'searchable_attributes' do
      result = described_class.searchable_attributes

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '.search_list' do
    xit 'search_list' do
      options = {}
      result = described_class.search_list(options)

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
