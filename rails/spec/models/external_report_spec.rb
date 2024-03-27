require File.expand_path('../../spec_helper', __FILE__)

describe ExternalReport do
  let(:logging)         { false }
  let(:clazz)           { FactoryBot.create(:portal_clazz, logging: logging) }
  let(:offering)        { FactoryBot.create(:portal_offering, {runnable: FactoryBot.create(:external_activity), clazz: clazz}) }
  let(:external_report) { FactoryBot.create(:external_report, url: 'https://example.com?cool=true') }
  let(:portal_teacher)  { FactoryBot.create(:portal_teacher)}
  let(:extra_params)    { {} }

  describe "#url_for_offering" do
    subject { external_report.url_for_offering(offering, portal_teacher.user, 'https', 'perfect.host.com', extra_params) }

    it "should handle report urls with parameters" do
      expect(subject.scan('?').size).to eq(1)
      expect(subject).to include('cool=true')
    end

    describe "when report type is `offering`" do
      it "should include the correct parameters" do
        expect(subject).to include('reportType=offering', 'offering=', 'classOfferings=', 'class=', 'token=', 'username=')
      end

      it "should have correctly escaped url params" do
        uri = URI.parse(subject)
        query_hash = Rack::Utils.parse_query(uri.query)
        expect(query_hash['offering']).to start_with('https://')
        expect(query_hash['classOfferings']).to start_with('https://')
        expect(query_hash['class']).to start_with('https://')
      end

      describe "when extra params are not provided" do
        it "should not researcher=true and other additional params" do
          expect(subject).not_to include("studentId=")
          expect(subject).not_to include("activityId=123")
          expect(subject).not_to include('studentId=')
        end
      end

      describe "when extra params are provided" do
        let(:external_activity) { FactoryBot.create(:external_activity) }
        let(:offering) { FactoryBot.create(:portal_offering, {runnable: external_activity}) }
        let(:learner) { FactoryBot.create(:full_portal_learner, {offering: offering }) }
        let(:extra_params) { {student_id: learner.student.id, activity_id: 123, researcher: true } }

        it "should include the correct parameters" do
          expect(subject).to include("studentId=#{learner.user.id}")
          expect(subject).to include("activityId=123")
          expect(subject).to include("researcher=true")
        end
      end
    end
  end

  describe "#url_for_class" do
    let(:extra_params)    { {} }
    subject { external_report.url_for_class(offering.clazz, portal_teacher.user, 'https', 'perfect.host.com', extra_params) }

    it "should handle report urls with parameters" do
      expect(subject.scan('?').size).to eq(1)
      expect(subject).to include('cool=true')
    end
    it "should include the correct parameters" do
      expect(subject).to include('reportType=class', 'classOfferings=',
        'class=', 'token=', 'username=')
      end
    it "should have correctly escaped url params" do
      uri = URI.parse(subject)
      query_hash = Rack::Utils.parse_query(uri.query)
      expect(query_hash['class']).to start_with('https://')
      expect(query_hash['classOfferings']).to start_with('https://')
    end

    describe "with logging not enabled" do
      let(:logging) { false }

      it "should not include the logging parameter" do
        expect(subject).not_to include('logging=')
      end
    end

    describe "with logging enabled" do
      let(:logging) { true }

      it "should include the logging parameter" do
        expect(subject).to include('logging=true')
      end
    end

    describe "when extra params are not provided" do
      it "should not include the researcher parameter" do
        expect(subject).not_to include('researcher=')
      end
    end

    describe "when extra params are provided" do
      let(:extra_params) { {researcher: true } }

      it "should include the correct parameters" do
        expect(subject).to include("researcher=true")
      end
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
end
