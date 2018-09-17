# frozen_string_literal: false

require 'spec_helper'

RSpec.describe Portal::ClazzesHelper, type: :helper do

  # TODO: auto-generated
  describe '#render_portal_clazz_partial' do
    xit 'works' do
      result = helper.render_portal_clazz_partial('name', FactoryGirl.create(:portal_clazz))

      expect(result).not_to be_nil
    end
  end

end
