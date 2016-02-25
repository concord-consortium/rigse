# encoding: utf-8
require 'spec_helper'

describe LearnerProcessingEvent do

  let(:learner)                  { FactoryGirl.create(:full_portal_learner) }
  let(:learner_processing_event) { LearnerProcessingEvent.new(learner, processing_time)}
  let(:lara_start)               { 10.minutes.ago }
  let(:lara_end)                 { 5.minutes.ago  }
  let(:portal_start)             { 2.minutes.ago  }
  let(:record)                   { LearnerProcessingEvent.build_proccesing_event(learner, lara_start, lara_end, portal_start)}
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

end
