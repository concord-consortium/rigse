require 'spec_helper'

describe "/security_questions/_fields.html.haml" do
  
  before(:each) do
      # Stub
      @security_questions = []
      @security_questions << stub_model(SecurityQuestion, :question => "Why?")
      @security_questions << stub_model(SecurityQuestion, :question => "What?")
      assigns[:security_questions] = @security_questions
  end
  
  it "should display the options" do  
     render :partial => "/security_questions/fields"
     response.should have_tag('select') do
       with_tag('option', :text => 'Why?')
       with_tag('option', :text => 'What?')
     end
  end
  
end
