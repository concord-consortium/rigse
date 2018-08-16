  require File.expand_path('../../spec_helper', __FILE__)

describe Portal::PadletBookmark do
  let(:bookmark_wrapper) { double(:padlet_url => "http://fake_padlet.com") }
  before(:each) do
    allow(PadletWrapper).to receive(:new) { bookmark_wrapper }
  end

  describe "Class methods" do
    describe "#create_for_user(user)" do
      describe "the default padlet names" do

        context "when none of the existing names contain ordinal numbers" do
          let(:user) {mock_model(User, :anonymous? => false, :email=>'k@gmail.com')}
          let(:found_items) do
            [ double(:name => 'foo'), double(:name => 'bar'), double(:name => 'baz')]
          end

          it "shuld use a name with an ordinal found-size + 1" do
            allow(Portal::PadletBookmark).to receive_messages(:for_user => found_items)
            expect(Portal::PadletBookmark.create_for_user(user).name).to match(/my 4th padlet/i)
          end
        end

        context "when some of the names contain ordinal numbers" do
          let(:user) {mock_model(User, :anonymous? => false, :email=>'k@gmail.com')}
          let(:found_items) do
            [ double(:name => 'my 3rd padlet'), double(:name => 'bar'), double(:name => 'my 7th padlet')]
          end

          it "shuld use a name with existing max ordinal size + 1" do
            allow(Portal::PadletBookmark).to receive_messages(:for_user => found_items)
            expect(Portal::PadletBookmark.create_for_user(user).name).to match(/my 8th padlet/i)
          end
        end
      end

    end
    describe "user_can_make?(user)" do
      context "when the portal allows PadletBookmarks" do
        before(:each) do
          allow(Portal::Bookmark).to receive_messages(:allowed_types => [Portal::PadletBookmark])
        end

        context "when the user is anonymous" do
          let(:user) { mock_model(User, :anonymous? => true)}
          it "shouldn't let the user make a PadletBookmark" do
            expect(Portal::PadletBookmark.user_can_make?(user)).to be_falsey
          end
        end
        context "the user is a regular user" do
          let(:user) { mock_model(User, :anonymous? => false)}
          it "should let the user make a PadletBookmark" do
            expect(Portal::PadletBookmark.user_can_make?(user)).to be_truthy
          end
        end
      end
      context "when the portal doesn't allow PadletBookmarks" do
        before(:each) do
          allow(Portal::Bookmark).to receive_messages(:allowed_types => [])
        end
        context "the user is a regular user" do
          let(:user) { mock_model(User, :anonymous? => false)}
          it "should let the user make a PadletBookmark" do
            expect(Portal::PadletBookmark.user_can_make?(user)).to be_falsey
          end
        end
        context "the user is an anonymous user" do
          let(:user) { mock_model(User, :anonymous? => true)}
          it "should let the user make a PadletBookmark" do
            expect(Portal::PadletBookmark.user_can_make?(user)).to be_falsey
          end
        end
      end
    end
  end
end

