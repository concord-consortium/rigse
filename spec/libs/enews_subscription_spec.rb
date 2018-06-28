require 'spec_helper'

describe EnewsSubscription do

  # Establish values specific to a particular email subscription service.
  Enews_API_Key = '07d2723fc46087ed0873ab0b4668c029-us2'
  Enews_API_URI = 'us2.api.mailchimp.com/3.0/lists'
  Enews_List_ID = '4ca9f8d47e'
  Enews_Mimetype = {'Content-Type'=>'application/json'}

  # Establish a mock user profile.
  User_First = "Fred"
  User_Last  = "Flintstone"
  User_EMail = "#{User_First}.#{User_Last}@bedrockgravel.com"

  def construct_test_uri
    'https://user:' + Enews_API_Key + '@' + Enews_API_URI + '/' + Enews_List_ID + '/members/' + Digest::MD5.hexdigest(User_EMail)
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
        WebMock.stub_request(:put, construct_test_uri)
               .with(:body => subscribed_request_body, :headers => Enews_Mimetype)
               .to_return(:status => 200,
                          :body => {'subscribed': 'subscribed'}.to_json,
                          :headers => {})

        result = EnewsSubscription.set_status(User_EMail, 'subscribed', User_First, User_Last)

        WebMock.should have_requested(:put, construct_test_uri)
               .with(:body => subscribed_request_body, :headers => Enews_Mimetype)
               .once

        expect(result).to eq({"subscribed"=>"subscribed"})
      end
    end

    context "to unsubscribed" do
      it "correctly indicates user is unsubscribed ({subscribed: unsubscribed})" do
        subscribed_request_body = construct_request_body('unsubscribed', User_First, User_Last)
        fake_response_unsubscribed =
        WebMock.stub_request(:put, construct_test_uri)
               .with(:body => subscribed_request_body, :headers => Enews_Mimetype)
               .to_return(:status => 200,
                          :body => {'subscribed': 'unsubscribed'}.to_json,
                          :headers => {})

        result = EnewsSubscription.set_status(User_EMail, 'unsubscribed', User_First, User_Last)

        WebMock.should have_requested(:put, construct_test_uri)
               .with(:body => subscribed_request_body, :headers => Enews_Mimetype)
               .once

        expect(result).to eq({"subscribed"=>"unsubscribed"})
      end
    end
  end

  describe "get_status" do

    context "with a user subscribed" do
      it "correctly indicates user is subscribed ({subscribed: true})" do

        WebMock.stub_request(:get, construct_test_uri)
               .with(:body => {email_address: User_EMail}.to_json,
                     :headers => Enews_Mimetype)
               .to_return(:status => 200,
                          :body => {'subscribed': true}.to_json,
                          :headers => {})

        result = EnewsSubscription.get_status(User_EMail)

        WebMock.should have_requested(:get, construct_test_uri)
                .with(:body => {email_address: User_EMail}.to_json,
                      :headers => Enews_Mimetype)
                .once

        expect(result).to eq({"subscribed"=>true})
      end
    end

    context "with unsubscribed email address" do
      it "returns subscribed equals false" do

        WebMock.stub_request(:get, construct_test_uri)
               .with(:body => {email_address: User_EMail}.to_json,
                     :headers => Enews_Mimetype)
              .to_return(:status => 200,
                         :body => {'subscribed': false}.to_json,
                         :headers => {})

        result = EnewsSubscription.get_status(User_EMail)

        WebMock.should have_requested(:get, construct_test_uri)
               .with(:body => {email_address: User_EMail}.to_json,
                     :headers => Enews_Mimetype)
               .once

        expect(result).to eq({"subscribed"=>false})
      end
    end

  end
end
