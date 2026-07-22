require 'spec_helper'

describe OidcAuthContext do
  let(:user)    { FactoryBot.create(:user) }
  let(:client)  { Admin::OidcClient.create!(name: 'C', sub: 'sub-ctx', user: user, capabilities: ['enroll_student']) }
  let(:student) { FactoryBot.create(:full_portal_student) }
  let(:clazz)   { FactoryBot.create(:portal_clazz, students: [student]) }
  let(:offering) { FactoryBot.create(:portal_offering, clazz: clazz) }

  def context_for(env)
    OidcAuthContext.new(env)
  end

  describe 'with a populated env' do
    let(:env) do
      {
        'portal.auth_client_id'     => client.id,
        'portal.forwarded_student'  => true,
        'portal.origin_offering_id' => offering.id,
        'portal.origin_class_hash'  => clazz.class_hash
      }
    end

    it 'resolves the client by id' do
      expect(context_for(env).client).to eq(client)
    end

    it 'reports acting_as_forwarded_user?' do
      expect(context_for(env).acting_as_forwarded_user?).to be true
    end

    it 'exposes origin ids and hash' do
      ctx = context_for(env)
      expect(ctx.origin_offering_id).to eq(offering.id)
      expect(ctx.origin_class_hash).to eq(clazz.class_hash)
    end

    it 'resolves origin offering and clazz objects' do
      ctx = context_for(env)
      expect(ctx.origin_offering).to eq(offering)
      expect(ctx.origin_clazz).to eq(clazz)
    end

    it 'delegates capability? to the client' do
      ctx = context_for(env)
      expect(ctx.capability?('enroll_student')).to be true
      expect(ctx.capability?('send_teacher_email')).to be false
    end
  end

  describe 'accepts a request-like object' do
    it 'reads env from anything responding to #env' do
      request = double('request', env: { 'portal.forwarded_student' => true })
      expect(OidcAuthContext.new(request).acting_as_forwarded_user?).to be true
    end
  end

  describe 'with an empty or nil env' do
    it 'returns all-false/nil for an empty env' do
      ctx = context_for({})
      expect(ctx.client).to be_nil
      expect(ctx.acting_as_forwarded_user?).to be false
      expect(ctx.origin_offering_id).to be_nil
      expect(ctx.origin_offering).to be_nil
      expect(ctx.origin_clazz).to be_nil
      expect(ctx.capability?('enroll_student')).to be false
    end

    it 'treats nil as an empty env' do
      ctx = context_for(nil)
      expect(ctx.acting_as_forwarded_user?).to be false
      expect(ctx.capability?('enroll_student')).to be false
    end
  end
end
