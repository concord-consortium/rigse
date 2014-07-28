  require File.expand_path('../../spec_helper', __FILE__)

describe Portal::PadletBookmark do
  let(:bookmark_wrapper) { mock(:padlet_url => "http://fake_padlet.com") }
  before(:each) do
    PadletWrapper.stub!(:new) { bookmark_wrapper }
  end

  describe "Class methods" do
    describe "#create_for_user(user)" do
      describe "the default padlet names" do

        context "when none of the existing names contain ordinal numbers" do
          let(:user) {mock_model(User, :anonymous? => false, :email=>'k@gmail.com')}
          let(:found_items) do
            [ mock(:name => 'foo'), mock(:name => 'bar'), mock(:name => 'baz')]
          end

          it "shuld use a name with an ordinal found-size + 1" do
            Portal::PadletBookmark.stub!(:for_user => found_items)
            Portal::PadletBookmark.create_for_user(user).name.should match(/my 4th padlet/i)
          end
        end

        context "when some of the names contain ordinal numbers" do
          let(:user) {mock_model(User, :anonymous? => false, :email=>'k@gmail.com')}
          let(:found_items) do
            [ mock(:name => 'my 3rd padlet'), mock(:name => 'bar'), mock(:name => 'my 7th padlet')]
          end

          it "shuld use a name with existing max ordinal size + 1" do
            Portal::PadletBookmark.stub!(:for_user => found_items)
            Portal::PadletBookmark.create_for_user(user).name.should match(/my 8th padlet/i)
          end
        end
      end

    end
    describe "user_can_make?(user)" do
      context "when the portal allows PadletBookmarks" do
        before(:each) do
          Portal::Bookmark.stub!(:allowed_types => [Portal::PadletBookmark])
        end

        context "when the user is anonymous" do
          let(:user) { mock_model(User, :anonymous? => true)}
          it "shouldn't let the user make a PadletBookmark" do
            Portal::PadletBookmark.user_can_make?(user).should be_false
          end
        end
        context "the user is a regular user" do
          let(:user) { mock_model(User, :anonymous? => false)}
          it "should let the user make a PadletBookmark" do
            Portal::PadletBookmark.user_can_make?(user).should be_true
          end
        end
      end
      context "when the portal doesn't allow PadletBookmarks" do
        before(:each) do
          Portal::Bookmark.stub!(:allowed_types => [])
        end
        context "the user is a regular user" do
          let(:user) { mock_model(User, :anonymous? => false)}
          it "should let the user make a PadletBookmark" do
            Portal::PadletBookmark.user_can_make?(user).should be_false
          end
        end
        context "the user is an anonymous user" do
          let(:user) { mock_model(User, :anonymous? => true)}
          it "should let the user make a PadletBookmark" do
            Portal::PadletBookmark.user_can_make?(user).should be_false
          end
        end
      end
    end
  end
end

