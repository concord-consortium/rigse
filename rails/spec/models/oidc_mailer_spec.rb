require 'spec_helper'

RSpec.describe OidcMailer, type: :mailer do
  before(:each) do
    generate_default_settings_with_mocks
  end

  describe '#send_message' do
    let(:mail) { OidcMailer.send_message('user@example.com', 'Test Subject', 'Hello world') }

    it 'sends to the specified recipient' do
      expect(mail.to).to eq(['user@example.com'])
    end

    it 'uses the configured from address' do
      expect(mail.from).to include(APP_CONFIG[:help_email])
    end

    it 'sets the subject' do
      expect(mail.subject).to eq('Test Subject')
    end

    it 'includes the message in the body' do
      expect(mail.body.encoded).to include('Hello world')
    end

    it 'sends as plain text' do
      expect(mail.content_type).to match(/text\/plain/)
    end
  end
end
