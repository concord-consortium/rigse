# frozen_string_literal: false

require 'spec_helper'

RSpec.describe HomePage do
  let(:user) { FactoryBot.create(:user) }

  # TODO: auto-generated
  describe '#redirect' do
    it 'redirect' do
      settings = double('settings')
      home_page = described_class.new(user, settings)
      result = home_page.redirect

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#content' do
    xit 'content' do
      settings = double('settings')
      home_page = described_class.new(user, settings)
      result = home_page.content

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#view_options' do
    xit 'view_options' do
      settings = double('settings')
      home_page = described_class.new(user, settings)
      result = home_page.view_options

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#layout' do
    xit 'layout' do
      settings = double('settings')
      home_page = described_class.new(user, settings)
      result = home_page.layout

      expect(result).not_to be_nil
    end
  end

end
