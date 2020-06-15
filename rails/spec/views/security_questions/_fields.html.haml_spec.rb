require File.expand_path('../../../spec_helper', __FILE__)

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
     assert_select('select') do
       assert_select('option', :text => 'Why?')
       assert_select('option', :text => 'What?')
     end
  end
  
end
