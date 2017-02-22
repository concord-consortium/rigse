require File.expand_path('../../spec_helper', __FILE__)

describe Portal::Bookmark do
  describe "Class methods" do
    describe "#available_types" do
      it "should return an array of subclasses" do
        expect(Portal::Bookmark.available_types).to be_kind_of Array
      end
    end
  end

  describe "Bookmark instance" do
    it "should preprocess provided URL" do
      b = Portal::Bookmark.new
      b.url = "abc.com"
      expect(b.url).to eql("http://abc.com")
      b.url = "/abc.com"
      expect(b.url).to eql("http://abc.com")
      b.url = "//abc.com"
      expect(b.url).to eql("http://abc.com")
      b.url = "http://abc.com"
      expect(b.url).to eql("http://abc.com")
      b.url = "https://abc.com"
      expect(b.url).to eql("https://abc.com")
    end
  end
end
