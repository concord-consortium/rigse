# frozen_string_literal: false

require 'spec_helper'


RSpec.describe Report::Offering::Page, type: :model do

  # TODO: auto-generated
  describe '#respondables' do
    xit 'respondables' do
      section_report = []
      offering = FactoryGirl.create(:portal_offering)
      page = Page.new
      page = described_class.new(section_report, offering, page)
      klazz = ('klazz')
      result = page.respondables(klazz)

      expect(result).not_to be_nil
    end
  end

end
