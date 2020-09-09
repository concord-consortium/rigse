# frozen_string_literal: false

require 'spec_helper'

RSpec.describe JsHelper, type: :helper do

  # TODO: auto-generated
  describe '#js_string_value' do
    it 'works' do
      result = helper.js_string_value('object')

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#safe_js' do
    it 'works' do
      result = helper.safe_js('page', 'dom_id') {}

      expect(result).not_to be_nil
    end
  end


  # TODO: auto-generated
  describe '#add_to_list' do
    it 'works' do
      result = helper.add_to_list('pattern')

      expect(result).to be_nil
    end
  end

end
