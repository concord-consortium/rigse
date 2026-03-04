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
end
