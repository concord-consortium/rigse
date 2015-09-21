require 'spec_helper'

describe MiscController do

  describe "GET preflight" do
  	it "returns the preflight page without error" do
  	  get :preflight
  	end
  end
end