require 'spec_helper'
describe "/portal/learners/_embeddable_open_response.html.haml" do
  
  before(:each) do
    view.stub(:saveable_for_learner).and_return(saveable)
  end
  let(:answer_text){ "My answer" }
  let(:submitted)  { true }
  let(:saveable)   { mock("Saveable", {submitted?: submitted, submitted_answer: answer_text}) }
  let(:embeddable) { mock("embeddable", {prompt: "What is the sun made from?", is_required: false }) }
  let(:learner)    { mock("Learner", {}) }
  let(:locals)     {{ embeddable: embeddable, learner: learner}}

  describe "When the student has submitted an answer" do
    let(:submitted)  { true }
    it "should display render the users answer" do 
      render :partial => "embeddable_open_response", :locals => locals
      rendered.should =~ /#{answer_text}/
    end
  end

  describe "When the student hasn't submitted an answer" do
    let(:submitted)  { false }
    let(:answer_text){ nil }
    it "should not have any problem rendering" do
      render :partial => "embeddable_open_response", :locals => locals
    end
  end
end
