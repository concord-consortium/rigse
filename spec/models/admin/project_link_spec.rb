require 'spec_helper'

describe Admin::ProjectLink do

  describe "#name and #href and #link_id" do
    it "should be required" do
      expect(Admin::ProjectLink.new(name: 'foo', href: 'bar', link_id:'/foo/bar').valid?).to be_true
      expect(Admin::ProjectLink.new(name: 'foo', href: '', link_id: '/foo').valid?).to be_false
      expect(Admin::ProjectLink.new(name: '', href: 'bar', link_id: '/bar').valid?).to be_false
      expect(Admin::ProjectLink.new(name: '', href: '', link_id:'/').valid?).to be_false
      expect(Admin::ProjectLink.new(name: 'foo', href: 'bar', link_id:'').valid?).to be_false
      expect(Admin::ProjectLink.new().valid?).to be_false
    end
  end
end
