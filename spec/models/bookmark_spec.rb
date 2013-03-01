require File.expand_path('../../spec_helper', __FILE__)

describe Bookmark do
  describe "Class methods" do
    describe "#available_types" do
      it "should return an array of subclasses" do
        Bookmark.available_types.should be_kind_of Array
      end
      it "should include all subclasses of Bookmark" do
        class Frog < Bookmark
        end
        Bookmark.available_types.should include Frog
      end
    end
  end
end
