require 'spec_helper'

describe Admin::ProjectLink do

  describe "#name and #href" do
    it "should be required" do
      expect(Admin::ProjectLink.new(name: 'foo', href: 'bar').valid?).to be_true
      expect(Admin::ProjectLink.new(name: 'foo', href: '').valid?).to be_false
      expect(Admin::ProjectLink.new(name: '', href: 'bar').valid?).to be_false
      expect(Admin::ProjectLink.new(name: '', href: '').valid?).to be_false
      expect(Admin::ProjectLink.new().valid?).to be_false
    end
  end
end
