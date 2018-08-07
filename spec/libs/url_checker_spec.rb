require File.expand_path('../../spec_helper', __FILE__)

require 'fakeweb'

describe UrlChecker do
  before(:all) do
    @small_image_url = "http://example.com/small_image.jpg"
    @medium_image_url = "http://example.com/medium_image.jpg"
    @huge_image_url = "http://example.com/huge_image.jpg"
    @non_existant = "http://example.com/not_found.jpg"

    FakeWeb.register_uri(:head, @small_image_url, :status => ["200", "OK"],:content_type => "image/jpeg", :content_length => 100)
    FakeWeb.register_uri(:head, @medium_image_url, :status => ["200", "OK"], :content_type => "image/jpeg", :content_length => 1000)
    FakeWeb.register_uri(:head, @huge_image_url, :status => ["200", "OK"], :content_type => "image/jpeg", :content_length => 100000000)
    FakeWeb.register_uri(:head, @non_existant, :status => ["404", "Not Found"])
  end

  it "should validate good image urls" do
      [@small_image_url, @medium_image_url].each do |img|  
        expect(UrlChecker.valid?(img)).to be true
        expect(UrlChecker.valid?(img)).to be true
      end
  end
  
  it "should not validate good image urls that are too big" do
    expect(UrlChecker.valid?(@huge_image_url,  :max_size => 99999999)).to be false
    expect(UrlChecker.valid?(@medium_image_url,:max_size =>100000)).to be true
  end
  
  it "should not validate bad image urls" do
    expect(UrlChecker.valid?(@non_existant)).to be false
  end
  
end
