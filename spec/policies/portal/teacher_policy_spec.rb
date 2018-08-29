# frozen_string_literal: false

require 'spec_helper'

RSpec.describe Portal::TeacherPolicy do

  # TODO: auto-generated
  describe '#show?' do
    it 'show?' do
      teacher_policy = described_class.new(nil, nil)
      result = teacher_policy.show?

      expect(result).to be_nil
    end
  end

end
