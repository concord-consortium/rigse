# encoding: utf-8
require 'spec_helper'

describe API::V1::CreateCollaboration do
  let(:protocol) { 'https://' }
  let(:domain)   { "#{protocol}portal.org/" }
  let(:student1) { FactoryBot.create(:full_portal_student) }
  let(:student2) { FactoryBot.create(:full_portal_student) }
  let(:students) { [student1, student2] }
  let(:offering) do
    offering = FactoryBot.create(:portal_offering)
    clazz = offering.clazz
    clazz.students = [student1, student2]
    clazz.save!
    offering
  end
  let(:clazz) { offering.clazz }
  let(:params) do
    {
      'offering_id' => offering.id,
      'owner_id' => student1.id,
      'students' => [
        {
          'id' => student1.id,
          'password' => 'password' # this is valid password, see users factory.
        },
        {
          'id' => student2.id,
          'password' => 'password'
        }
      ],
      'protocol' => protocol,
      'host_with_port' => URI(domain).host
    }
  end

  describe "Failing collaboration validations" do
    subject { API::V1::CreateCollaboration.new(params) }

    describe "missing owner" do
      before { params.delete('owner_id') }
      it { is_expected.to have(1).error_on :owner_id }
    end

    describe "missing offering" do
      before { params.delete('offering_id') }
      it { is_expected.to have(1).error_on :offering_id }
    end

    describe "incorrect student ID" do
      before { params['students'][1]['id'] = 99999999 }
      it { is_expected.to have(1).error_on :"students[1]" }
    end
  end

  describe "#call" do
    it "should generate collaboration object and return true when successful" do
      create_collaboration = API::V1::CreateCollaboration.new(params)
      result = create_collaboration.call
      expect(result[:id]).not_to be_nil
      expect(result[:collaborators_data_url]).not_to be_nil
      expect(result[:external_activity_url]).to be_nil
      expect(create_collaboration.collaboration).to_not be_nil
    end

    describe "should respect protocol" do
      subject do
        create_collaboration = API::V1::CreateCollaboration.new(params)
        result = create_collaboration.call
        result[:collaborators_data_url]
      end
      describe "http" do
        let (:protocol) { 'http://' }
        it { is_expected.to start_with(domain) }
      end
      describe "https" do
        let (:protocol) { 'https://' }
        it { is_expected.to start_with(domain) }
      end
    end

    context "when offering is an external activity" do
      context "without append_auth_token set" do
        before do
          offering.runnable = FactoryBot.create(:external_activity)
          offering.save!
        end

        it "should also generate external activity URL" do
          create_collaboration = API::V1::CreateCollaboration.new(params)
          result = create_collaboration.call
          ea_url = result[:external_activity_url]
          expect(ea_url).not_to be_nil
          uri = URI.parse(ea_url)
          query = URI.decode_www_form(uri.query)
          data_url_param = ['collaborators_data_url', result[:collaborators_data_url]]
          domain_param = ['domain', domain]
          domain_uid_param = ["domain_uid", "#{student1.user.id}"]
          logging_param = ["logging", "false"]
          expect(query).to match_array([data_url_param, domain_param, domain_uid_param, logging_param])
        end
      end

      context "with append_auth_token set" do
        before do
          offering.runnable = FactoryBot.create(:external_activity, {:append_auth_token => true})
          offering.save!
        end

        it "should also generate external activity URL with a token" do
          create_collaboration = API::V1::CreateCollaboration.new(params)
          result = create_collaboration.call
          ea_url = result[:external_activity_url]
          expect(ea_url).not_to be_nil
          uri = URI.parse(ea_url)
          query = URI.decode_www_form(uri.query)

          # since the token value is dynamic test directly and remove from match_array test below
          # this assumes the token is the last parameter in the url
          token_param, token = query.pop()
          expect(token_param).to eq("token")
          expect(token).not_to be_nil

          data_url_param = ['collaborators_data_url', result[:collaborators_data_url]]
          domain_param = ['domain', domain]
          domain_uid_param = ["domain_uid", "#{student1.user.id}"]
          logging_param = ["logging", "false"]
          expect(query).to match_array([data_url_param, domain_param, domain_uid_param, logging_param])
        end
      end
    end

    it "should return false when params are incorrect, collaboration should be nil" do
      create_collaboration = API::V1::CreateCollaboration.new({})
      expect(create_collaboration.call).to be false
      expect(create_collaboration.collaboration).to be_nil
    end

    describe "collaboration object (Portal::Collaboration instance)" do
      let (:collaboration) do
        create_collaboration = API::V1::CreateCollaboration.new(params)
        create_collaboration.call
        create_collaboration.collaboration
      end

      it "should belong to the correct owner" do
        expect(collaboration.owner.id).to eql(params['owner_id'])
      end

      it "should belong to the correct offering" do
        expect(collaboration.offering.id).to eql(params['offering_id'])
      end

      it "should have the correct students (collaborators)" do
        expect(collaboration.students).to match_array(students)
      end

      describe "when owner isn't provided in students list" do
        before { params['students'].delete_at(0) }
        it "it should be added to collaborators anyway" do
          expect(collaboration.students).to match_array(students)
        end
      end
    end

    describe "side effects of collaboration generation" do
      let (:create_collaboration) { API::V1::CreateCollaboration.new(params) }

      it "should generate learner objects for every student" do
        expect(offering.learners.length).to eql(0)
        create_collaboration.call
        offering.reload
        expect(offering.learners.map { |l| l.student }).to match_array(students)
      end

      it "shold update the last_run attribute of all learners" do
        start = Time.now
        max_delta_seconds = 2
        create_collaboration.call
        offering.reload
        offering.learners.each do |l|
          expect(l.last_run - start).to be < max_delta_seconds
        end
      end
    end
  end


  # TODO: auto-generated
  describe '#call' do
    it 'call' do
      create_collaboration = described_class.new
      result = create_collaboration.call

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#owner_valid?' do
    it 'owner_valid?' do
      create_collaboration = described_class.new
      result = create_collaboration.owner_valid?

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#students_valid?' do
    it 'students_valid?' do
      create_collaboration = described_class.new
      result = create_collaboration.students_valid?

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#offering_valid?' do
    it 'offering_valid?' do
      create_collaboration = described_class.new
      result = create_collaboration.offering_valid?

      expect(result).not_to be_nil
    end
  end


end
