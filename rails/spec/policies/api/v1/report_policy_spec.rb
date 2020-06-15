# frozen_string_literal: false

require 'spec_helper'

RSpec.describe API::V1::ReportPolicy do

  # TODO: auto-generated
  describe '#show?' do
    it 'show?' do
      report_policy = described_class.new(nil, nil)
      result = report_policy.show?

      expect(result).to be_nil
    end
  end

end
