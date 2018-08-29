# frozen_string_literal: false

require 'spec_helper'

RSpec.describe DefaultReportService do


  # TODO: auto-generated
  describe '.instance' do
    it 'instance' do
      result = described_class.instance

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#load_env' do
    xit 'load_env' do
      default_report_service = described_class.new
      varname = double('varname')
      result = default_report_service.load_env(varname)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#reportViewUrl' do
    it 'reportViewUrl' do
      default_report_service = described_class.new
      result = default_report_service.reportViewUrl

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#report_domain_matchers' do
    it 'report_domain_matchers' do
      default_report_service = described_class.new
      result = default_report_service.report_domain_matchers

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#url_for' do
    it 'url_for' do
      default_report_service = described_class.new
      api_offering_url = double('api_offering_url')
      user = Factory.create(:user)
      result = default_report_service.url_for(api_offering_url, user)

      expect(result).not_to be_nil
    end
  end

end
