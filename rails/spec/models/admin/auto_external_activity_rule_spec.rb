require 'spec_helper'

describe Admin::AutoExternalActivityRule do
  let(:non_author_user)  { FactoryBot.create(:confirmed_user) }
  let(:author_user)      { FactoryBot.generate(:author_user) }
  let(:slug)             { "test" }
  let(:allow_patterns)   { ".*" }
  let(:rule)             { FactoryBot.create(:admin_auto_external_activity_rule, slug: slug, allow_patterns: allow_patterns, user: author_user) }
  let(:valid_attributes) {
    { name: "Test", slug: "test", description: "This is a test rule", allow_patterns: allow_patterns, user: author_user }
  }

  it "should create a new instance given valid attributes" do
    Admin::AutoExternalActivityRule.create!(valid_attributes)
  end

  describe "#name" do
    it "should be required" do
      expect(Admin::AutoExternalActivityRule.new(valid_attributes.merge(name: '')).valid?).to be_falsey
    end
  end

  describe "#slug" do
    it "should be required" do
      expect(Admin::AutoExternalActivityRule.new(valid_attributes.merge(slug: '')).valid?).to be_falsey
    end

    it "should be unique" do
      expect(Admin::AutoExternalActivityRule.create(valid_attributes).valid?).to be_truthy
      expect(Admin::AutoExternalActivityRule.create(valid_attributes).valid?).to be_falsey
    end

    it "should be limited to only contain letters, numbers, underscores, and dashes" do
      expect(Admin::AutoExternalActivityRule.new(valid_attributes.merge(slug: 'valid-slug')).valid?).to be_truthy
      expect(Admin::AutoExternalActivityRule.new(valid_attributes.merge(slug: 'valid-slug-2')).valid?).to be_truthy
      expect(Admin::AutoExternalActivityRule.new(valid_attributes.merge(slug: '3-valid_slug')).valid?).to be_truthy
      expect(Admin::AutoExternalActivityRule.new(valid_attributes.merge(slug: 'invalid/slug')).valid?).to be_falsey
      expect(Admin::AutoExternalActivityRule.new(valid_attributes.merge(slug: 'invalid.slug')).valid?).to be_falsey
    end
  end

  describe "#description" do
    it "should be required" do
      expect(Admin::AutoExternalActivityRule.new(valid_attributes.merge(description: '')).valid?).to be_falsey
    end
  end

  describe "#allow_patterns" do
    it "should be required" do
      expect(Admin::AutoExternalActivityRule.new(valid_attributes.merge(allow_patterns: '')).valid?).to be_falsey
    end
  end

  describe "#user" do
    it "should be required" do
      expect(Admin::AutoExternalActivityRule.new(valid_attributes.merge(user: nil)).valid?).to be_falsey
    end

    it "should be an author" do
      expect(Admin::AutoExternalActivityRule.new(valid_attributes.merge(user: non_author_user)).valid?).to be_falsey
    end

    it "should be valid with an author" do
      expect(Admin::AutoExternalActivityRule.new(valid_attributes).valid?).to be_truthy
    end
  end

  describe "#matches_pattern?" do
    let(:allow_patterns) { "https?://example.com/*\nhttp://foo.com/*" }

    it "should return false if the URL does not match any pattern" do
      expect(rule.matches_pattern?("http://notmatching.com")).to be_falsey
    end

    it "should return true if the URL matches a pattern" do
      expect(rule.matches_pattern?("http://example.com/test")).to be_truthy
    end

    it "should return true if the URL matches another pattern" do
      expect(rule.matches_pattern?("http://foo.com/test")).to be_truthy
    end
  end
end
