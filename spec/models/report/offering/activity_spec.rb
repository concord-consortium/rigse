# frozen_string_literal: false

require 'spec_helper'


RSpec.describe Report::Offering::Activity, type: :model do



  # TODO: auto-generated
  describe '#respondables' do
    it 'respondables' do
      investigation_report = double('investigation_report')
      offering = FactoryGirl.create(:portal_offering)
      activity = Activity.new
      activity = described_class.new(investigation_report, offering, activity)
      klazz = double('klazz')
      result = activity.respondables(klazz)

      expect(result).not_to be_nil
    end
  end

end
