# frozen_string_literal: false

require 'spec_helper'


RSpec.describe Import::Import, type: :model do

  # TODO: auto-generated
  describe '.in_progress' do # scope test
    it 'supports named scope in_progress' do
      expect(described_class.limit(3).in_progress('x')).to all(be_a(described_class))
    end
  end

  # TODO: auto-generated
  describe '#working?' do
    xit 'working?' do
      import = described_class.new
      result = import.working?

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#finished?' do
    xit 'finished?' do
      import = described_class.new
      result = import.finished?

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#in_progress' do
    xit 'in_progress' do
      import = described_class.new
      result = import.in_progress

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#send_mail' do
    xit 'send_mail' do
      import = described_class.new
      user = Factory.create(:user)
      result = import.send_mail(user)

      expect(result).not_to be_nil
    end
  end

end
