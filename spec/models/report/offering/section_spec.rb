# frozen_string_literal: false

require 'spec_helper'


RSpec.describe Report::Offering::Section, type: :model do



  # TODO: auto-generated
  describe '#respondables' do
    it 'respondables' do
      activity_report = double('activity_report')
      offering = Factory.create(:portal_offering)
      section = Section.new
      section = described_class.new(activity_report, offering, section)
      klazz = ('klazz')
      result = section.respondables(klazz)

      expect(result).not_to be_nil
    end
  end

end
