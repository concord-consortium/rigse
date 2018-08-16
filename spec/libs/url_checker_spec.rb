require File.expand_path('../../spec_helper', __FILE__)

describe UrlChecker do
  before do
    @small_image_url = "http://example.com/small_image.jpg"
    @medium_image_url = "http://example.com/medium_image.jpg"
    @huge_image_url = "http://example.com/huge_image.jpg"
    @non_existant = "http://example.com/not_found.jpg"

    stub_request(:head, @small_image_url).
      to_return(status: 200,
        headers: {
          'Content-Length' => 3,
          'Content-Type' => "image/jpeg"
        })

    stub_request(:head, @medium_image_url).
      to_return(status: 200,
        headers: {
          'Content-Length' => 1000,
          'Content-Type' => "image/jpeg"
        })

    stub_request(:head, @huge_image_url).
      to_return(status: 200,
        headers: {
          'Content-Length' => 100000000,
          'Content-Type' => "image/jpeg"
        })

    stub_request(:head, @non_existant)
      .to_return(status: 404)
  end

  it "should validate good image urls" do
    [@small_image_url, @medium_image_url].each do |img|
      expect(UrlChecker.valid?(img)).to be true
    end
  end

  it "should not validate good image urls that are too big" do
    expect(UrlChecker.valid?(@huge_image_url, :max_size => 99999999)).to be false
    expect(UrlChecker.valid?(@medium_image_url, :max_size => 100000)).to be true
  end

  it "should not validate bad image urls" do
    expect(UrlChecker.valid?(@non_existant)).to be false
  end
end
