require File.expand_path('../../spec_helper', __FILE__)

describe Bookmark do
  describe "Class methods" do
    describe "#available_types" do
      it "should return an array of subclasses" do
        Bookmark.available_types.should be_kind_of Array
      end
    end
  end
end
