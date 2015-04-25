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
end
