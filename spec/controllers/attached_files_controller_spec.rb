require 'spec_helper'

describe AttachedFilesController do  
  before(:each) do
    @attached_file = Factory.create(:attached_file)
    AttachedFile.stub!(:find).and_return(@attached_file)
  end
  
  describe "responding to DELETE destroy" do
    it "should destroy the attached file when requested by an approved user" do      
      @admin_user = login_admin
      
      @attached_file.stub!(:changeable?).and_return(true)
      @attached_file.should_receive(:changeable?).with(@admin_user)
      @attached_file.should_receive(:destroy)
      
      delete :destroy, :id => @attached_file.id
      response.should redirect_to(resource_page_path(@attached_file.attachable_id))
    end
    
    it "should not destroy the attached file when requested by a non-approved user" do
      @anonymous_user = login_anonymous
      
      @attached_file.stub!(:changeable?).and_return(false)
      @attached_file.should_receive(:changeable?).with(@anonymous_user)
      @attached_file.should_not_receive(:destroy)
      
      delete :destroy, :id => @attached_file.id
      response.should redirect_to(resource_page_path(@attached_file.attachable_id))
    end
  end  
end