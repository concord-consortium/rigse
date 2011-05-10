require 'spec_helper'

describe "/activities/_show.otml.haml" do
  it "renders without error" do
    render :locals => {:teacher_mode => false, :activity => Factory.build(:activity)}
  end
end