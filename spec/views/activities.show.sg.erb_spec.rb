require 'spec_helper'

describe "/activities/show.sg.erb" do
  before(:each) do
    model = stub_model(Embeddable::MwModelerPage, :new_record? => false, :id => 1, :name => "Model", :description => "Desc")
    or1 = stub_model(Embeddable::OpenResponse, :new_record? => false, :id => 1, :name => "OR 1", :description => "Desc", :prompt => "<b>OR 1</b>")
    or2 = stub_model(Embeddable::OpenResponse, :new_record? => false, :id => 2, :name => "OR 2", :description => "Desc", :prompt => "<b>OR 2</b>")
    mc1 = stub_model(Embeddable::MultipleChoice, :new_record? => false, :id => 1, :name => "MC 1", :description => "Desc", :prompt => "<b>MC 1</b>",
                     :choices => [
                       stub_model(Embeddable::MultipleChoiceChoice, :new_record? => false, :id => 1, :multiple_choice_id => 1, :choice => "MC 1 - Choice 1"),
                       stub_model(Embeddable::MultipleChoiceChoice, :new_record? => false, :id => 2, :multiple_choice_id => 1, :choice => "MC 1 - Choice 2"),
                       stub_model(Embeddable::MultipleChoiceChoice, :new_record? => false, :id => 3, :multiple_choice_id => 1, :choice => "MC 1 - Choice 3")
                     ]
    )
    mc2 = stub_model(Embeddable::MultipleChoice, :new_record? => false, :id => 2, :name => "MC 2", :description => "Desc", :prompt => "<b>MC 2</b>",
                     :choices => [
                       stub_model(Embeddable::MultipleChoiceChoice, :new_record? => false, :id => 4, :multiple_choice_id => 2, :choice => "MC 2 - Choice 1"),
                       stub_model(Embeddable::MultipleChoiceChoice, :new_record? => false, :id => 5, :multiple_choice_id => 2, :choice => "MC 2 - Choice 2"),
                       stub_model(Embeddable::MultipleChoiceChoice, :new_record? => false, :id => 6, :multiple_choice_id => 2, :choice => "MC 2 - Choice 3")
                     ]
    )
    assigns[:activity] = @activity = stub_model(Activity,
      :new_record? => false, :id => 1, :name => "My Activity", :description => "Desc", :is_template => false, :position => 1, :teacher_only => false, :sections => [
        stub_model(Section, :new_record? => false, :id => 1, :name => "My Section", :description => "Desc", :activity_id => 1, :position => 1, :pages => [
                   stub_model(Page, :new_record? => false, :id => 1, :name => "My Page", :description => "Desc", :section_id => 1, :position => 1, :page_elements => [
                              stub_model(PageElement, :new_record? => false, :id => 1, :page_id => 1, :embeddable => model ),
                              stub_model(PageElement, :new_record? => false, :id => 2, :page_id => 1, :embeddable => or1 ),
                              stub_model(PageElement, :new_record? => false, :id => 3, :page_id => 1, :embeddable => or2 ),
                              stub_model(PageElement, :new_record? => false, :id => 4, :page_id => 1, :embeddable => mc1 ),
                              stub_model(PageElement, :new_record? => false, :id => 5, :page_id => 1, :embeddable => mc2 )
                  ]
                  )
        ]
        )
    ]
    )
  end

  it "renders the correct response templates list" do
    render
    reg = '"responseTemplates":'
    reg += '\s*?\[\s*?'
    2.times do |i|
      reg += Regexp.escape('"/activity/1/response-template/embeddable__open_response_') + (i+1).to_s + '",?\s*?'
    end
    2.times do |i|
      reg += Regexp.escape('"/activity/1/response-template/embeddable__multiple_choice_') + (i+1).to_s + '",?\s*?'
    end
    reg += '\],'
    response.should have_text(Regexp.new(reg))
  end

  it "renders the correct steps list" do
    render
    reg = '"pages":\s*?\[\s*?\{[^\}]*"steps":'
    reg += '\s*?\[\s*?'
    2.times do |i|
      reg += Regexp.escape('"/activity/1/page/1/step/embeddable__open_response_') + (i+1).to_s + '",?\s*?'
    end
    2.times do |i|
      reg += Regexp.escape('"/activity/1/page/1/step/embeddable__multiple_choice_') + (i+1).to_s + '",?\s*?'
    end
    reg += Regexp.escape('"/activity/1/page/1/step/final-step",') + '?\s*?'
    reg += '\],'
    response.should have_text(Regexp.new(reg))
  end
end
