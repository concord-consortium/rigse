# frozen_string_literal: false

require 'spec_helper'


RSpec.describe Portal::BookmarkVisit, type: :model do

  # TODO: auto-generated
  describe '.recent' do # scope test
    it 'supports named scope recent' do
      expect(described_class.limit(3).recent).to all(be_a(described_class))
    end
  end

end
