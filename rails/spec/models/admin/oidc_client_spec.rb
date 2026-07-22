require 'spec_helper'

describe Admin::OidcClient do
  let(:user) { FactoryBot.create(:user) }

  describe 'validations' do
    it 'is valid with name, sub, and user' do
      client = Admin::OidcClient.new(name: 'Test Client', sub: '12345', user: user)
      expect(client).to be_valid
    end

    it 'requires name' do
      client = Admin::OidcClient.new(sub: '12345', user: user)
      expect(client).not_to be_valid
      expect(client.errors[:name]).to include("can't be blank")
    end

    it 'requires sub' do
      client = Admin::OidcClient.new(name: 'Test', user: user)
      expect(client).not_to be_valid
      expect(client.errors[:sub]).to include("can't be blank")
    end

    it 'requires user' do
      client = Admin::OidcClient.new(name: 'Test', sub: '12345')
      expect(client).not_to be_valid
    end

    it 'requires unique sub' do
      Admin::OidcClient.create!(name: 'First', sub: '12345', user: user)
      duplicate = Admin::OidcClient.new(name: 'Second', sub: '12345', user: user)
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:sub]).to include("has already been taken")
    end
  end

  describe 'scopes' do
    it '.active returns only active records' do
      active = Admin::OidcClient.create!(name: 'Active', sub: 'a1', user: user, active: true)
      inactive = Admin::OidcClient.create!(name: 'Inactive', sub: 'a2', user: user, active: false)
      expect(Admin::OidcClient.active).to include(active)
      expect(Admin::OidcClient.active).not_to include(inactive)
    end
  end

  describe 'associations' do
    it 'belongs to user' do
      client = Admin::OidcClient.create!(name: 'Test', sub: '12345', user: user)
      expect(client.user).to eq(user)
    end
  end

  describe 'conditional user presence' do
    it 'rejects a null user when requires_forwarded_jwt is false' do
      client = Admin::OidcClient.new(name: 'Test', sub: 'p1', requires_forwarded_jwt: false)
      expect(client).not_to be_valid
      expect(client.errors[:user]).to be_present
    end

    it 'allows a null user when requires_forwarded_jwt is true' do
      client = Admin::OidcClient.new(name: 'Test', sub: 'p2', requires_forwarded_jwt: true)
      expect(client).to be_valid
    end

    it 'allows a user when requires_forwarded_jwt is false' do
      client = Admin::OidcClient.new(name: 'Test', sub: 'p3', requires_forwarded_jwt: false, user: user)
      expect(client).to be_valid
    end
  end

  describe '#capability?' do
    it 'returns true for a stored capability and false otherwise' do
      client = Admin::OidcClient.create!(name: 'Test', sub: 'c1', user: user, capabilities: ['enroll_student'])
      expect(client.capability?('enroll_student')).to be true
      expect(client.capability?('update_offering_state')).to be false
    end

    it 'returns false and does not raise when the capabilities column is NULL' do
      client = Admin::OidcClient.create!(name: 'Test', sub: 'c2', user: user)
      client.update_column(:capabilities, nil)
      client.reload
      expect { client.capability?('enroll_student') }.not_to raise_error
      expect(client.capability?('enroll_student')).to be false
    end
  end

  describe 'capabilities validation' do
    it 'rejects an unknown capability identifier' do
      client = Admin::OidcClient.new(name: 'Test', sub: 'v1', user: user, capabilities: ['not_a_real_capability'])
      expect(client).not_to be_valid
      expect(client.errors[:capabilities]).to be_present
    end

    it 'accepts recognized capabilities' do
      client = Admin::OidcClient.new(name: 'Test', sub: 'v2', user: user, capabilities: ['enroll_student', 'send_teacher_email'])
      expect(client).to be_valid
    end

    it 'no-ops on nil or empty capabilities' do
      nil_client = Admin::OidcClient.new(name: 'Test', sub: 'v3', user: user)
      empty_client = Admin::OidcClient.new(name: 'Test', sub: 'v4', user: user, capabilities: [])
      expect(nil_client).to be_valid
      expect(empty_client).to be_valid
    end
  end
end
