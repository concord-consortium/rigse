require 'spec_helper'
require 'rake'

describe 'oidc forwarded-capabilities tasks' do
  let(:user) { FactoryBot.create(:user) }
  let(:sub)  { 'google-sa-sub-rake' }
  let!(:client) { Admin::OidcClient.create!(name: 'Service', sub: sub, user: user) }

  before do
    Rake.application.rake_require('tasks/oidc_forwarded_capabilities')
    Rake::Task.define_task(:environment)
    ENV['SUB'] = sub
  end

  after(:each) do
    %w[oidc:grant_forwarded_capabilities oidc:verify_forwarded_capabilities oidc:require_forwarded_jwt].each do |name|
      Rake::Task[name].reenable
    end
    ENV.delete('SUB')
  end

  def invoke(name)
    Rake.application.invoke_task(name)
  end

  describe 'oidc:grant_forwarded_capabilities' do
    it 'grants all three capabilities and preserves the mapped user' do
      invoke('oidc:grant_forwarded_capabilities')
      client.reload
      expect(client.capabilities).to match_array(%w[enroll_student update_offering_state send_teacher_email])
      expect(client.user_id).to eq(user.id)
      expect(client.requires_forwarded_jwt).to be false
    end

    it 'is idempotent (union) on a re-run' do
      client.update!(capabilities: ['enroll_student'])
      invoke('oidc:grant_forwarded_capabilities')
      expect(client.reload.capabilities).to match_array(%w[enroll_student update_offering_state send_teacher_email])
    end
  end

  describe 'oidc:verify_forwarded_capabilities' do
    it 'succeeds when all capabilities are present' do
      client.update!(capabilities: %w[enroll_student update_offering_state send_teacher_email])
      expect { invoke('oidc:verify_forwarded_capabilities') }.to output(/OK:/).to_stdout
    end

    it 'aborts when a capability is missing' do
      client.update!(capabilities: ['enroll_student'])
      expect { invoke('oidc:verify_forwarded_capabilities') }.to raise_error(SystemExit).and output(/FAIL:/).to_stderr
    end
  end

  describe 'oidc:require_forwarded_jwt' do
    it 'sets requires_forwarded_jwt and nulls user_id together' do
      invoke('oidc:require_forwarded_jwt')
      client.reload
      expect(client.requires_forwarded_jwt).to be true
      expect(client.user_id).to be_nil
    end
  end
end
