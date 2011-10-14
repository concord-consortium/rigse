require File.expand_path('../../../spec_helper', __FILE__)

describe "/activities/_show.otml.haml" do
  it "renders without error" do
    # the following should work because rspec is supposed to pick up the partial from the describe block or file name
    # however it fails set the format correctly in this case, whereas when explicity setting the partial file name rails
    # figures the format from the file name
    # render :locals => {:teacher_mode => false, :activity => Factory.build(:activity)}
    render :partial => 'activities/show.otml', :locals => {:teacher_mode => false, :activity => Factory.build(:activity)}
  end
end