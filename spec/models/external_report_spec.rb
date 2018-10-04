require File.expand_path('../../spec_helper', __FILE__)

describe ExternalReport do
  let(:runnable)        { FactoryBot.create(:external_activity) }
  let(:args)            { {runnable: runnable} }
  let(:offering)        { FactoryBot.create(:portal_offering, args) }
  let(:external_report) { FactoryBot.create(:external_report,
    url: 'https://example.com?cool=true'
    )}
  let(:portal_teacher)  { FactoryBot.create(:portal_teacher)}

  describe "#url_for_offering" do
    subject { external_report.url_for_offering(offering, portal_teacher.user, 'https', 'perfect.host.com') }

    it "should handle report urls with parameters" do
      expect(subject.scan('?').size).to eq(1)
      expect(subject).to include('cool=true')
    end
    it "should include the correct parameters" do
      uri = URI.parse(subject)
      expect(subject).to include('reportType=offering', 'offering=', 'classOfferings=',
        'class=', 'token=', 'username=')
    end
    it "should have correctly escaped url params" do
      uri = URI.parse(subject)
      query_hash = Rack::Utils.parse_query(uri.query)
      expect(query_hash['offering']).to start_with('https://')
      expect(query_hash['classOfferings']).to start_with('https://')
      expect(query_hash['class']).to start_with('https://')
    end
  end

  describe "#url_for_class" do
    subject { external_report.url_for_class(offering.clazz_id, portal_teacher.user, 'https', 'perfect.host.com') }

    it "should handle report urls with parameters" do
      expect(subject.scan('?').size).to eq(1)
      expect(subject).to include('cool=true')
    end
    it "should include the correct parameters" do
      uri = URI.parse(subject)
      expect(subject).to include('reportType=class', 'classOfferings=',
        'class=', 'token=', 'username=')
    end
    it "should have correctly escaped url params" do
      uri = URI.parse(subject)
      query_hash = Rack::Utils.parse_query(uri.query)
      expect(query_hash['class']).to start_with('https://')
      expect(query_hash['classOfferings']).to start_with('https://')
    end
  end


  # TODO: auto-generated
  describe '#options_for_client' do
    it 'options_for_client' do
      external_report = described_class.new
      result = external_report.options_for_client

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#options_for_report_type' do
    it 'options_for_report_type' do
      external_report = described_class.new
      result = external_report.options_for_report_type

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#url_for_offering' do
    xit 'url_for_offering' do
      user = FactoryBot.create(:user)
      protocol = double('protocol')
      host = double('host')
      result = external_report.url_for_offering(offering, user, protocol, host)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#url_for_class' do
    xit 'url_for_class' do
      class_id = double('class_id')
      user = FactoryBot.create(:user)
      protocol = double('protocol')
      host = double('host')
      result = external_report.url_for_class(class_id, user, protocol, host)

      expect(result).not_to be_nil
    end
  end


end
