require 'test_helper'

class ActivityStepTest < ActiveSupport::TestCase
  
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
  
  test "add step to activity " do
    @activity = Activity.create(:title => 'test activity')
    @xhtml = Xhtml.create(:name => 'first html', :contents => "this is the contents")
    @xhtml.activities << @activity
    @xhtml.save
    assert (@activity.activity_steps.size > 0)
    assert (ActivityStep.find(:first, :conditions => {:activity_id => @activity.id}))
    @activity = Activity.find(:first, :conditions => {:title => 'test activity'} )
    assert(@activity)
    @xhtml = @activity.activity_steps[0].step;
    assert(@xhtml.name == 'first html')
  end
  
  
end
