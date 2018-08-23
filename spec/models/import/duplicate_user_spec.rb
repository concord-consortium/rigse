# frozen_string_literal: false

require 'spec_helper'


RSpec.describe Import::DuplicateUser, type: :model do


  # TODO: auto-generated
  describe '#duplicate_by_login?' do
    it 'duplicate_by_login?' do
      duplicate_user = described_class.new
      result = duplicate_user.duplicate_by_login?

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#duplicate_by_email?' do
    it 'duplicate_by_email?' do
      duplicate_user = described_class.new
      result = duplicate_user.duplicate_by_email?

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#duplicate_by_login_and_email?' do
    it 'duplicate_by_login_and_email?' do
      duplicate_user = described_class.new
      result = duplicate_user.duplicate_by_login_and_email?

      expect(result).not_to be_nil
    end
  end

end
