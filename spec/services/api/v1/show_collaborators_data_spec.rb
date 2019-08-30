# frozen_string_literal: false

require 'spec_helper'

RSpec.describe API::V1::ShowCollaboratorsData do
  let(:offering) { FactoryBot.create(:portal_offering) }
  let(:student1) { FactoryBot.create(:full_portal_student) }
  let(:student2) { FactoryBot.create(:full_portal_student) }
  let(:student2) { FactoryBot.create(:full_portal_student) }
  let(:clazz) { FactoryBot.create(:portal_clazz, students: [student1, student2]) }

  before(:each) do
    @collaboration = Portal::Collaboration.new
    @collaboration.offering = offering
    @collaboration.students << student1
    @collaboration.students << student2
    @collaboration.save
    offering.clazz = clazz
    offering.save
  end

  describe '#call' do
    it 'call' do
      show_collaborators_data = described_class.new({
        collaboration_id: @collaboration.id,
        host_with_port: "test.portal.com",
        protocol: "http"
      })
      result = show_collaborators_data.call

      expect(result).not_to be_nil
      expect(result.length).to eq(2)
      expect(result[0][:name]).to eq(student1.user.name)
      expect(result[0][:email]).to eq(student1.user.email)
      expect(result[0][:learner_id]).to eq(offering.find_or_create_learner(student1).id)
      expect(result[0][:endpoint_url]).to eq(offering.find_or_create_learner(student1).remote_endpoint_url)
      expect(result[0][:platform_id]).to eq(APP_CONFIG[:site_url])
      expect(result[0][:platform_user_id]).to eq(student1.user.id.to_s)
      expect(result[0][:resource_link_id]).to eq(offering.id)
      expect(result[0][:context_id]).to eq(clazz.class_hash)
      expect(result[0][:context_id]).to eq(clazz.class_hash)
      expect(result[0][:class_info_url]).to eq(clazz.class_info_url("http", "test.portal.com"))

      expect(result[1][:name]).to eq(student2.user.name)
      expect(result[1][:email]).to eq(student2.user.email)
      expect(result[1][:learner_id]).to eq(offering.find_or_create_learner(student2).id)
      expect(result[1][:endpoint_url]).to eq(offering.find_or_create_learner(student2).remote_endpoint_url)
      expect(result[1][:platform_id]).to eq(APP_CONFIG[:site_url])
      expect(result[1][:platform_user_id]).to eq(student2.user.id.to_s)
      expect(result[1][:resource_link_id]).to eq(offering.id)
      expect(result[1][:context_id]).to eq(clazz.class_hash)
      expect(result[1][:context_id]).to eq(clazz.class_hash)
      expect(result[1][:class_info_url]).to eq(clazz.class_info_url("http", "test.portal.com"))
    end
  end
end
