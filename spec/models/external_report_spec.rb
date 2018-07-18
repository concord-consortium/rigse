require File.expand_path('../../spec_helper', __FILE__)

describe ExternalReport do
  let(:runnable)        { Factory.create(:external_activity) }
  let(:args)            { {runnable: runnable} }
  let(:offering)        { Factory.create(:portal_offering, args) }
  let(:external_report) { Factory.create(:external_report,
    url: 'https://example.com?cool=true'
    )}
  let(:portal_teacher)  { Factory.create(:portal_teacher)}

  describe "#url_for_offering" do
    subject { external_report.url_for_offering(offering, portal_teacher.user, 'https', 'perfect.host.com') }

    it "should handle report urls with parameters" do
      expect(subject.scan('?')).to have(1).question_mark
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
      expect(subject.scan('?')).to have(1).question_mark
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
end
