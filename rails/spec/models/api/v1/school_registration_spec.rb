# frozen_string_literal: false

require 'spec_helper'


RSpec.describe API::V1::SchoolRegistration do

  # TODO: auto-generated
  describe '.for_country_and_zipcode' do
    it 'for_country_and_zipcode' do
      country_id = 'country_id'
      zipcode = ('zipcode')
      result = described_class.for_country_and_zipcode(country_id, zipcode)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '.find' do
    xit 'find' do
      params = []
      result = described_class.find(params)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '.json_data' do
    xit 'json_data' do
      school = double('school')
      result = described_class.json_data(school)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#new_school' do
    it 'new_school' do
      school_registration = described_class.new
      result = school_registration.new_school

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#school_is_valid' do
    it 'school_is_valid' do
      school_registration = described_class.new
      result = school_registration.school_is_valid

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#name' do
    it 'name' do
      school_registration = described_class.new
      result = school_registration.name

      expect(result).to be_nil
    end
  end

  # TODO: auto-generated
  describe '#save' do
    it 'save' do
      school_registration = described_class.new
      result = school_registration.save

      expect(result).not_to be_nil
    end
  end

end
