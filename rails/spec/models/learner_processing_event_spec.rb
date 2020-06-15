# encoding: utf-8
require 'spec_helper'

describe LearnerProcessingEvent do

  let(:learner)                  { FactoryBot.create(:full_portal_learner) }
  let(:learner_processing_event) { LearnerProcessingEvent.new(learner, processing_time)}
  let(:lara_start)               { 10.minutes.ago }
  let(:lara_end)                 { 5.minutes.ago  }
  let(:portal_start)             { 2.minutes.ago  }
  let(:answers_length)           { 1 }
  let(:record)                   {
    LearnerProcessingEvent.build_proccesing_event(
      learner, lara_start, lara_end, portal_start, answers_length)
  }
  before(:each) do

  end

  describe "The expected content of a good record with lara start time" do
    it "should have a learner" do
      expect(record.learner).to be_a(Portal::Learner)
    end

    it "should have a duration of 10 minutes" do
      expect(record.duration).to match "10 minutes"
    end

  end
  describe "The expected content for a record without a lara start time" do
    let(:lara_start) { nil }
    it "should have a duration of 5 minutes" do
      expect(record.duration).to match "5 minutes"
    end
  end
  describe "The expected content for a record without a lara start time or end time" do
    let(:lara_start) { nil }
    let(:lara_end)   { nil }
    it "should have a duration of 2 minutes" do
      expect(record.duration).to match "2 minutes"
    end
  end
  describe "The expected average" do
    it "should be N/A when there is no data" do
      expect(LearnerProcessingEvent.human_avg(12)).to match "N/A"
    end

    it "should be a human readable form of the time since the lara_start" do
      record.save!
      expect(LearnerProcessingEvent.human_avg(12)).to match "10 minutes 0 seconds"
    end
  end


  # TODO: auto-generated
  describe '.humanize' do
    it 'humanize' do
      secs = 15
      result = described_class.humanize(secs)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '.build_proccesing_event' do
    it 'build_proccesing_event' do
      learner = Portal::Learner.new
      lara_start = Time.now
      lara_end = Time.now
      portal_start = Time.now
      answers_length = 1
      result = described_class.build_proccesing_event(learner, lara_start, lara_end, portal_start, answers_length)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#log_event' do
    it 'log_event' do
      learner_processing_event = described_class.new
      answers_length = 1
      result = learner_processing_event.log_event(answers_length)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '.avg_delay' do
    it 'avg_delay' do
      result = described_class.avg_delay

      expect(result).to be_nil
    end
  end

  # TODO: auto-generated
  describe '.max_delay' do
    it 'max_delay' do
      result = described_class.max_delay

      expect(result).to be_nil
    end
  end

  # TODO: auto-generated
  describe '.histogram' do
    it 'histogram' do
      result = described_class.histogram

      expect(result).not_to be_nil
    end
  end


end
