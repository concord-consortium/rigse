require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/activities/edit.html.erb" do
  include ActivitiesHelper
  
  before(:each) do
    assigns[:activity] = @activity = stub_model(Activity,
      :new_record? => false,
      :title => "value for title",
      :context => "value for context",
      :opportunities => "value for opportunities",
      :objectives => "value for objectives",
      :procedures_opening => "value for procedures_opening",
      :procedures_engagement => "value for procedures_engagement",
      :procedures_closure => "value for procedures_closure",
      :assessment => "value for assessment",
      :reflection => "value for reflection"
    )
  end

  it "should render edit form" do
    render "/activities/edit.html.erb"
    
    response.should have_tag("form[action=#{activity_path(@activity)}][method=post]") do
      with_tag('input#activity_title[name=?]', "activity[title]")
      with_tag('textarea#activity_context[name=?]', "activity[context]")
      with_tag('textarea#activity_opportunities[name=?]', "activity[opportunities]")
      with_tag('textarea#activity_objectives[name=?]', "activity[objectives]")
      with_tag('textarea#activity_procedures_opening[name=?]', "activity[procedures_opening]")
      with_tag('textarea#activity_procedures_engagement[name=?]', "activity[procedures_engagement]")
      with_tag('textarea#activity_procedures_closure[name=?]', "activity[procedures_closure]")
      with_tag('textarea#activity_assessment[name=?]', "activity[assessment]")
      with_tag('textarea#activity_reflection[name=?]', "activity[reflection]")
    end
  end
end


