require File.expand_path('../../spec_helper', __FILE__)

describe Portal::Bookmark do
  describe "Class methods" do
    describe "#available_types" do
      it "should return an array of subclasses" do
        Portal::Bookmark.available_types.should be_kind_of Array
      end
    end
  end

  describe "Bookmark instance" do
    it "should preprocess provided URL" do
      b = Portal::Bookmark.new
      b.url = "abc.com"
      b.url.should eql("http://abc.com")
      b.url = "/abc.com"
      b.url.should eql("http://abc.com")
      b.url = "//abc.com"
      b.url.should eql("http://abc.com")
      b.url = "http://abc.com"
      b.url.should eql("http://abc.com")
      b.url = "https://abc.com"
      b.url.should eql("https://abc.com")
    end
  end
end
