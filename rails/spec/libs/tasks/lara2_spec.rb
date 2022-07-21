require 'spec_helper'
require 'rake'

describe "lara2:migrate_lara_urls_to_ap" do

  let (:empty_ap_url)     { "" }
  let (:non_https_ap_url) { "foo" }
  let (:good_ap_url)      { "https://ap.url/?answersSourceKey=foo" }

  let (:lara_tool) { FactoryBot.create(:tool, {name: "LARA"}) }
  let (:ap_tool)   { FactoryBot.create(:tool, {name: "ActivityPlayer"}) }

  let (:lara_activity) { FactoryBot.create(:external_activity, url: "https://lara.url/activities/123", tool: lara_tool)}
  let (:lara_sequence) { FactoryBot.create(:external_activity, url: "https://lara.url/sequences/456", tool: lara_tool)}
  let (:ap_activity) { FactoryBot.create(:external_activity, url: "https://lara.url/foo/bar/baz", tool: ap_tool)}
  let (:other_external_activity) { FactoryBot.create(:external_activity, url: "https://lara.url/foo/bar/baz", tool: lara_tool)}
  
  let (:invoke_task) { 
    Rake.application.invoke_task "lara2:migrate_lara_urls_to_ap"
  }

  before do
    Rake.application.rake_require "tasks/lara2"
    Rake::Task.define_task(:environment)
  end

  after(:each) do
    # the magic to allow multiple tests on the same task...
    Rake::Task["lara2:migrate_lara_urls_to_ap"].reenable
  end

  it "fails on an empty AP url input" do
    allow(STDIN).to receive(:gets).and_return(empty_ap_url)
    expect { invoke_task }.to output(/ERROR: No AP url entered/).to_stdout
  end

  it "fails on a non https AP url input" do
    allow(STDIN).to receive(:gets).and_return(non_https_ap_url)
    expect { invoke_task }.to output(/ERROR: Should be https url/).to_stdout
  end

  it "fails with no LARA tool" do
    allow(STDIN).to receive(:gets).and_return(good_ap_url)
    expect { invoke_task }.to output(/ERROR: No LARA tool found/).to_stdout
  end  

  it "fails with a LARA tool but no ActivityPlayer tool" do
    lara_tool
    allow(STDIN).to receive(:gets).and_return(good_ap_url)
    expect { invoke_task }.to output(/ERROR: No ActivityPlayer tool found/).to_stdout
  end

  it "migrates urls" do
    lara_activity
    lara_sequence
    ap_activity
    other_external_activity

    expect(lara_activity.url).to eq("https://lara.url/activities/123")
    expect(lara_activity.tool).to eq(lara_tool)
  
    expect(lara_sequence.url).to eq("https://lara.url/sequences/456")
    expect(lara_sequence.tool).to eq(lara_tool)
  
    expect(ap_activity.url).to eq("https://lara.url/foo/bar/baz")
    expect(ap_activity.legacy_lara_url).to be_nil
    expect(ap_activity.tool).to eq(ap_tool)
  
    expect(other_external_activity.url).to eq("https://lara.url/foo/bar/baz")
    expect(other_external_activity.legacy_lara_url).to be_nil
    expect(other_external_activity.tool).to eq(lara_tool)
  
    allow(STDIN).to receive(:gets).and_return(good_ap_url)
    expect { invoke_task }.to output(/Migrated 2 out of 3 LARA urls found/).to_stdout

    lara_activity.reload
    lara_sequence.reload
    ap_activity.reload
    other_external_activity.reload

    # activity url is rewritten and legacy url is set
    expect(lara_activity.url).to eq("#{good_ap_url}&activity=https%3A%2F%2Flara.url%2Fapi%2Fv1%2Factivities%2F123.json")
    expect(lara_activity.legacy_lara_url).to eq("https://lara.url/activities/123")
    expect(lara_activity.tool).to eq(ap_tool)
    
    # sequence url is rewritten and legacy url is set
    expect(lara_sequence.url).to eq("#{good_ap_url}&sequence=https%3A%2F%2Flara.url%2Fapi%2Fv1%2Fsequences%2F456.json")
    expect(lara_sequence.legacy_lara_url).to eq("https://lara.url/sequences/456")
    expect(lara_sequence.tool).to eq(ap_tool)

    # no change
    expect(ap_activity.url).to eq("https://lara.url/foo/bar/baz")
    expect(ap_activity.legacy_lara_url).to be_nil
    expect(ap_activity.tool).to eq(ap_tool)
  
    # no change
    expect(other_external_activity.url).to eq("https://lara.url/foo/bar/baz")
    expect(other_external_activity.legacy_lara_url).to be_nil
    expect(other_external_activity.tool).to eq(lara_tool)
  end  
end

describe "lara2:reset_external_activity_urls_to_legacy_lara_url" do

  let (:empty_ap_url)     { "" }
  let (:non_https_ap_url) { "foo" }
  let (:good_ap_url)      { "https://ap.url/?answersSourceKey=foo" }

  let (:lara_tool) { FactoryBot.create(:tool, {name: "LARA"}) }
  let (:ap_tool)   { FactoryBot.create(:tool, {name: "ActivityPlayer"}) }

  let (:lara_activity) { FactoryBot.create(:external_activity, url: "https://lara.url/activities/123", tool: lara_tool)}
  let (:ap_activity_1) { FactoryBot.create(:external_activity, url: "https://ap.url/456", legacy_lara_url: "https://lara.url/activities/456", tool: ap_tool)}
  let (:ap_activity_2) { FactoryBot.create(:external_activity, url: "https://ap.url/789", legacy_lara_url: "https://lara.url/activities/789", tool: ap_tool)}
  let (:ap_activity_no_legacy_url) { FactoryBot.create(:external_activity, url: "https://ap.url/abc", tool: ap_tool)}
  
  let (:invoke_task) { 
    Rake.application.invoke_task "lara2:reset_external_activity_urls_to_legacy_lara_url"
  }

  before do
    Rake.application.rake_require "tasks/lara2"
    Rake::Task.define_task(:environment)
  end

  after(:each) do
    # the magic to allow multiple tests on the same task...
    Rake::Task["lara2:reset_external_activity_urls_to_legacy_lara_url"].reenable
  end

  it "fails with no LARA tool" do
    expect { invoke_task }.to output(/ERROR: No LARA tool found/).to_stdout
  end  

  it "fails with a LARA tool but no ActivityPlayer tool" do
    lara_tool
    expect { invoke_task }.to output(/ERROR: No ActivityPlayer tool found/).to_stdout
  end

  it "fails when the confirmation input is not correct" do
    lara_tool
    ap_tool

    allow(STDIN).to receive(:gets).and_return("NO!")
    expect { invoke_task }.to output(/ERROR: Aborting reseting urls/).to_stdout
  end

  it "resets urls" do
    lara_activity
    ap_activity_1
    ap_activity_2
    ap_activity_no_legacy_url

    expect(lara_activity.url).to eq("https://lara.url/activities/123")
    expect(lara_activity.tool).to eq(lara_tool)
  
    expect(ap_activity_1.url).to eq("https://ap.url/456")
    expect(ap_activity_1.legacy_lara_url).to eq("https://lara.url/activities/456")
    expect(ap_activity_1.tool).to eq(ap_tool)
  
    expect(ap_activity_2.url).to eq("https://ap.url/789")
    expect(ap_activity_2.legacy_lara_url).to eq("https://lara.url/activities/789")
    expect(ap_activity_2.tool).to eq(ap_tool)
  
    expect(ap_activity_no_legacy_url.url).to eq("https://ap.url/abc")
    expect(ap_activity_no_legacy_url.legacy_lara_url).to be_nil
    expect(ap_activity_no_legacy_url.tool).to eq(ap_tool)

    allow(STDIN).to receive(:gets).and_return("YES")
    expect { invoke_task }.to output(/Reset 2 out of 2 AP urls found with legacy LARA urls/).to_stdout

    lara_activity.reload
    ap_activity_1.reload
    ap_activity_2.reload
    ap_activity_no_legacy_url.reload

    # no change for lara url
    expect(lara_activity.url).to eq("https://lara.url/activities/123")
    expect(lara_activity.tool).to eq(lara_tool)
    
    # ap_activity_1 url and tool is reset
    expect(ap_activity_1.url).to eq("https://lara.url/activities/456")
    expect(ap_activity_1.legacy_lara_url).to be_nil
    expect(ap_activity_1.tool).to eq(lara_tool)

    # ap_activity_2 url and tool is reset
    expect(ap_activity_2.url).to eq("https://lara.url/activities/789")
    expect(ap_activity_2.legacy_lara_url).to be_nil
    expect(ap_activity_2.tool).to eq(lara_tool)

    # no change for ap activity with no legacy url
    expect(ap_activity_no_legacy_url.url).to eq("https://ap.url/abc")
    expect(ap_activity_no_legacy_url.legacy_lara_url).to be_nil
    expect(ap_activity_no_legacy_url.tool).to eq(ap_tool)
  end  
end
