require 'spec_helper'

describe EnewsSubscription do

  # Establish values specific to a particular email subscription service.
  Enews_API_Key = '12345'
  Enews_Domain = 'example.com'
  Enews_List_ID = 'abcdef'
  Enews_Mimetype = {'Content-Type'=>'application/json'}

  # Stub module configuration
  before(:each) do
    stub_const('EnewsSubscription::Enews_api_key', Enews_API_Key)
    stub_const('EnewsSubscription::Enews_list_id', Enews_List_ID)
    stub_const('EnewsSubscription::Enews_uri', 'https://' + Enews_Domain)
  end

  # Establish a mock user profile.
  User_First = "Fred"
  User_Last  = "Flintstone"
  User_EMail = "#{User_First}.#{User_Last}@bedrockgravel.com"

  def construct_test_uri
    'https://' + Enews_Domain + '/' + Enews_List_ID + '/members/' + Digest::MD5.hexdigest(User_EMail)
  end

  describe "set_status" do

    def construct_request_body(status, first_name, last_name)
      {
        :email_address => "#{User_EMail}",
        :status => "#{status}",
        :merge_fields => {
          :FNAME => "#{first_name}",
          :LNAME => "#{last_name}"
          }
        }.to_json
    end

    context "to subscribed" do
      it "correctly indicates user is subscribed ({subscribed: subscribed})" do
        subscribed_request_body = construct_request_body('subscribed', User_First, User_Last)

        stub_request(:put, construct_test_uri).
          with(basic_auth: ['user', Enews_API_Key],
            body: subscribed_request_body,
            headers: Enews_Mimetype).
          to_return(status: 200,
            body: {'subscribed': 'subscribed'}.to_json,
            headers: {}
            )

        result = EnewsSubscription.set_status(User_EMail, 'subscribed', User_First, User_Last)

        expect(WebMock).to have_requested(:put, construct_test_uri).
          with(basic_auth: ['user', Enews_API_Key],
            body: subscribed_request_body,
            headers: Enews_Mimetype).
          once

        expect(result).to eq({"subscribed"=>"subscribed"})
      end
    end

    context "to unsubscribed" do
      it "correctly indicates user is unsubscribed ({subscribed: unsubscribed})" do
        subscribed_request_body = construct_request_body('unsubscribed', User_First, User_Last)

        stub_request(:put, construct_test_uri).
          with(basic_auth: ['user', Enews_API_Key],
            body: subscribed_request_body,
            headers: Enews_Mimetype
            ).
          to_return(:status => 200,
            :body => {'subscribed': 'unsubscribed'}.to_json,
            :headers => {}
            )

        result = EnewsSubscription.set_status(User_EMail, 'unsubscribed', User_First, User_Last)

        expect(WebMock).to have_requested(:put, construct_test_uri).
          with(basic_auth: ['user', Enews_API_Key],
            body: subscribed_request_body,
            headers: Enews_Mimetype).
          once

        expect(result).to eq({"subscribed"=>"unsubscribed"})
      end
    end
  end

  describe "get_status" do

    context "with a user subscribed" do
      it "correctly indicates user is subscribed ({subscribed: true})" do
        stub_request(:get, construct_test_uri).
          with(basic_auth: ['user', Enews_API_Key],
            body: {email_address: User_EMail}.to_json,
            headers: Enews_Mimetype
            ).
          to_return(:status => 200,
            body: {'subscribed': true}.to_json,
            headers: {}
            )

        result = EnewsSubscription.get_status(User_EMail)

        expect(WebMock).to have_requested(:get, construct_test_uri).
          with(basic_auth: ['user', Enews_API_Key],
            body: {email_address: User_EMail}.to_json,
            headers: Enews_Mimetype
            ).
          once

        expect(result).to eq({"subscribed"=>true})
      end
    end

    context "with unsubscribed email address" do
      it "returns subscribed equals false" do
        stub_request(:get, construct_test_uri).
          with(basic_auth: ['user', Enews_API_Key],
            body: {email_address: User_EMail}.to_json,
            headers: Enews_Mimetype
            ).
          to_return(:status => 200,
            body: {'subscribed': false}.to_json,
            headers: {}
            )

        result = EnewsSubscription.get_status(User_EMail)

        expect(WebMock).to have_requested(:get, construct_test_uri).
          with(basic_auth: ['user', Enews_API_Key],
            body: {email_address: User_EMail}.to_json,
            headers: Enews_Mimetype
            ).
          once

        expect(result).to eq({"subscribed"=>false})
      end
    end

  end

  # TODO: auto-generated
  describe '.build_uri' do
    it 'build_uri' do
      email = ('email')
      result = described_class.build_uri(email)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '.post_request' do
    xit 'post_request' do
      email = ('email')
      enews_data = ('enews_data')
      req_type = :put
      result = described_class.post_request(email, enews_data, req_type)

      expect(result).not_to be_nil
    end
  end

end
