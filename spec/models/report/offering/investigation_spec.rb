# frozen_string_literal: false

require 'spec_helper'


RSpec.describe Report::Offering::Investigation, type: :model do



  # TODO: auto-generated
  describe '#respondables' do
    it 'respondables' do
      offering = FactoryBot.create(:portal_offering)
      investigation = described_class.new(offering)
      klazz = double('klazz')
      result = investigation.respondables(klazz)

      expect(result).not_to be_nil
    end
  end

end
