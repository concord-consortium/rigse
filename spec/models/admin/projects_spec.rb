require 'spec_helper'

describe Admin::Project do
  let (:project) { FactoryGirl.create(:project) }

  it "should create a new instance given valid attributes" do
    valid_attributes = { name: "test" }
    Admin::Project.create!(valid_attributes)
  end

  it "should be linked to activities" do
    act = FactoryGirl.create(:activity)
    project.activities << act
    expect(project.activities.count).to eql(1)
  end

  it "should be linked to investigations" do
    inv = FactoryGirl.create(:investigation)
    project.investigations << inv
    expect(project.investigations.count).to eql(1)
  end

  it "should be linked to external activities" do
    ext_act = FactoryGirl.create(:external_activity)
    project.external_activities << ext_act
    expect(project.external_activities.count).to eql(1)
  end


  describe "#name" do
    it "should be required" do
      expect(Admin::Project.new(name: 'n').valid?).to be_true
      expect(Admin::Project.new(name: '').valid?).to be_false
      expect(Admin::Project.new().valid?).to be_false
    end
  end

  describe "#landing_page_slug" do
    it "should be optional" do
      expect(Admin::Project.new(name: 'n').valid?).to be_true
      expect(Admin::Project.new(name: 'n', landing_page_slug: '').valid?).to be_true
    end

    it "should be unique (except from nil or empty string)" do
      expect(Admin::Project.create(name: 'n', landing_page_slug: 'test').valid?).to be_true
      expect(Admin::Project.create(name: 'n', landing_page_slug: 'test').valid?).to be_false
      expect(Admin::Project.create(name: 'n', landing_page_slug: '').valid?).to be_true
      expect(Admin::Project.create(name: 'n', landing_page_slug: '').valid?).to be_true
      expect(Admin::Project.create(name: 'n').valid?).to be_true
      expect(Admin::Project.create(name: 'n').valid?).to be_true
    end

    it "should be limited to lower case letters, digits and '-' character" do
      expect(Admin::Project.new(name: 'n', landing_page_slug: 'valid-slug').valid?).to be_true
      expect(Admin::Project.new(name: 'n', landing_page_slug: 'valid-slug-2').valid?).to be_true
      expect(Admin::Project.new(name: 'n', landing_page_slug: '3-valid-slug').valid?).to be_true
      expect(Admin::Project.new(name: 'n', landing_page_slug: 'Invalid-slug').valid?).to be_false
      expect(Admin::Project.new(name: 'n', landing_page_slug: 'invalid/slug').valid?).to be_false
      expect(Admin::Project.new(name: 'n', landing_page_slug: 'invalid.slug').valid?).to be_false
      expect(Admin::Project.new(name: 'n', landing_page_slug: 'invalid:slug').valid?).to be_false
    end
  end
end
