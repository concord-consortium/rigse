# frozen_string_literal: false

require 'spec_helper'

RSpec.xdescribe DefaultRunnable do

  # TODO: auto-generated
  describe '.create_default_runnable_for_user' do
    it 'create_default_runnable_for_user' do
      user = double('user')
      name = double('name')
      logging = double('logging')
      result = described_class.create_default_runnable_for_user(user, name, logging)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '.create_default_investigation_for_user' do
    it 'create_default_investigation_for_user' do
      user = double('user')
      name = double('name')
      logging = double('logging')
      result = described_class.create_default_investigation_for_user(user, name, logging)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '.add_page_to_section' do
    it 'add_page_to_section' do
      section = double('section')
      name = double('name')
      html_content = double('html_content')
      page_description = double('page_description')
      result = described_class.add_page_to_section(section, name, html_content, page_description)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '.add_model_to_page' do
    it 'add_model_to_page' do
      page = double('page')
      model = double('model')
      result = described_class.add_model_to_page(page, model)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '.add_open_response_to_page' do
    it 'add_open_response_to_page' do
      page = double('page')
      question_prompt = double('question_prompt')
      result = described_class.add_open_response_to_page(page, question_prompt)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '.add_section_to_activity' do
    it 'add_section_to_activity' do
      activity = Activity.new
      section_name = double('section_name')
      section_desc = double('section_desc')
      result = described_class.add_section_to_activity(activity, section_name, section_desc)

      expect(result).not_to be_nil
    end
  end

end
