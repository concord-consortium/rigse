require File.expand_path('../../spec_helper', __FILE__)

describe 'PeerAcess' do
  let(:our_url)    { {} }
  let(:opts)       { {} }

  let(:controller) do
    controller = Object.new
    controller.extend PeerAccess
    controller.stub_chain(:request, :url) { our_url }
    controller
  end

  it "exists" do
    expect(controller).to_not be_nil
    expect(controller.request.url).to eq our_url
  end

  describe "ssl_if_we_are" do
    let(:urls) do
      [ "http://blarg.com/path", "https://foo.com/blorp",
        "http://bingo.com/thing?query" ]
    end
    
    describe "when we are using ssl" do
      let(:our_url) { "https://ssl.com/path"}
      it "should return https urls always" do
        urls.each do |u|
          uri = URI.parse(u)
          uri = controller.send(:ssl_if_we_are, uri)
          expect(uri.scheme).to eq 'https'
        end
      end
    end

    describe "When we are not using ssl" do
      let(:our_url) { "http://nossl.com/path"}
      it "should return the original scheme" do
        urls.each do |u|
          o_uri = URI.parse(u)
          uri = controller.send(:ssl_if_we_are, o_uri)
          expect(uri.scheme).to eq o_uri.scheme
        end
      end
    end
  end
end
