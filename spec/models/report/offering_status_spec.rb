# frozen_string_literal: false

require 'spec_helper'

RSpec.describe Report::OfferingStatus do
  
  let(:offering) { Factory.create(:portal_offering) }
  let(:requester) { Factory.create(:user) }
  let(:offering_status) { described_class.new(offering, requester) }
  let(:student) { Portal::Student.new }

  # TODO: auto-generated
  describe '#student_status_for' do
    it 'student_status_for' do
      
      result = offering_status.student_status_for(student)

      expect(result).to be_nil
    end
  end

  # TODO: auto-generated
  describe '#complete_percent' do
    xit 'complete_percent' do
      offering_status = described_class.new(offering, requester)
      result = offering_status.complete_percent(student)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#activity_complete_percent' do
    xit 'activity_complete_percent' do
      activity = Activity.new
      result = offering_status.activity_complete_percent(student, activity)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#collapsed' do
    xit 'collapsed' do
      result = offering_status.collapsed

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#activities_display_style' do
    xit 'activities_display_style' do
      result = offering_status.activities_display_style

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#offering_display_style' do
    xit 'offering_display_style' do
      result = offering_status.offering_display_style

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#runnable' do
    it 'runnable' do
      result = offering_status.runnable

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#student_activities' do
    it 'student_activities' do
      result = offering_status.student_activities

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#show_score?' do
    it 'show_score?' do
      result = offering_status.show_score?

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#number_of_scorables' do
    it 'number_of_scorables' do
      result = offering_status.number_of_scorables

      expect(result).not_to be_nil
    end
  end

end
