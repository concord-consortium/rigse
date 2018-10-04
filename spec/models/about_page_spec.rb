# frozen_string_literal: false

require 'spec_helper'


RSpec.describe AboutPage, type: :model do


  # TODO: auto-generated
  describe '#content' do
    it 'content' do
      user = FactoryBot.create(:user)
      settings = double('settings')
      preview_content = double('preview_content')
      about_page = described_class.new(user, settings, preview_content)
      result = about_page.content

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#view_options' do
    it 'view_options' do
      user = FactoryBot.create(:user)
      settings = double('settings')
      preview_content = double('preview_content')
      about_page = described_class.new(user, settings, preview_content)
      result = about_page.view_options

      expect(result).not_to be_nil
    end
  end

end
