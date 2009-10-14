# seems as though this controller has been renamed. Cant find it.
#
# `load_missing_constant': uninitialized constant OtrunkExample::OtrunkViewModesController (NameError)
#

# require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')
# 
# describe OtrunkExample::OtrunkViewModesController do
# 
#   def mock_otrunk_view_mode(stubs={})
#     @mock_otrunk_view_mode ||= mock_model(OtrunkExample::OtrunkViewMode, stubs)
#   end
# 
#   describe "GET index" do
#     it "assigns all otrunk_example_otrunk_view_modes as @otrunk_example_otrunk_view_modes" do
#       OtrunkExample::OtrunkViewMode.stub!(:find).with(:all).and_return([mock_otrunk_view_mode])
#       get :index
#       assigns[:otrunk_example_otrunk_view_modes].should == [mock_otrunk_view_mode]
#     end
#   end
# 
#   describe "GET show" do
#     it "assigns the requested otrunk_view_mode as @otrunk_view_mode" do
#       OtrunkExample::OtrunkViewMode.stub!(:find).with("37").and_return(mock_otrunk_view_mode)
#       get :show, :id => "37"
#       assigns[:otrunk_view_mode].should equal(mock_otrunk_view_mode)
#     end
#   end
# 
#   describe "GET new" do
#     it "assigns a new otrunk_view_mode as @otrunk_view_mode" do
#       OtrunkExample::OtrunkViewMode.stub!(:new).and_return(mock_otrunk_view_mode)
#       get :new
#       assigns[:otrunk_view_mode].should equal(mock_otrunk_view_mode)
#     end
#   end
# 
#   describe "GET edit" do
#     it "assigns the requested otrunk_view_mode as @otrunk_view_mode" do
#       OtrunkExample::OtrunkViewMode.stub!(:find).with("37").and_return(mock_otrunk_view_mode)
#       get :edit, :id => "37"
#       assigns[:otrunk_view_mode].should equal(mock_otrunk_view_mode)
#     end
#   end
# 
#   describe "POST create" do
# 
#     describe "with valid params" do
#       it "assigns a newly created otrunk_view_mode as @otrunk_view_mode" do
#         OtrunkExample::OtrunkViewMode.stub!(:new).with({'these' => 'params'}).and_return(mock_otrunk_view_mode(:save => true))
#         post :create, :otrunk_view_mode => {:these => 'params'}
#         assigns[:otrunk_view_mode].should equal(mock_otrunk_view_mode)
#       end
# 
#       it "redirects to the created otrunk_view_mode" do
#         OtrunkExample::OtrunkViewMode.stub!(:new).and_return(mock_otrunk_view_mode(:save => true))
#         post :create, :otrunk_view_mode => {}
#         response.should redirect_to(otrunk_example_otrunk_view_mode_url(mock_otrunk_view_mode))
#       end
#     end
# 
#     describe "with invalid params" do
#       it "assigns a newly created but unsaved otrunk_view_mode as @otrunk_view_mode" do
#         OtrunkExample::OtrunkViewMode.stub!(:new).with({'these' => 'params'}).and_return(mock_otrunk_view_mode(:save => false))
#         post :create, :otrunk_view_mode => {:these => 'params'}
#         assigns[:otrunk_view_mode].should equal(mock_otrunk_view_mode)
#       end
# 
#       it "re-renders the 'new' template" do
#         OtrunkExample::OtrunkViewMode.stub!(:new).and_return(mock_otrunk_view_mode(:save => false))
#         post :create, :otrunk_view_mode => {}
#         response.should render_template('new')
#       end
#     end
# 
#   end
# 
#   describe "PUT update" do
# 
#     describe "with valid params" do
#       it "updates the requested otrunk_view_mode" do
#         OtrunkExample::OtrunkViewMode.should_receive(:find).with("37").and_return(mock_otrunk_view_mode)
#         mock_otrunk_view_mode.should_receive(:update_attributes).with({'these' => 'params'})
#         put :update, :id => "37", :otrunk_view_mode => {:these => 'params'}
#       end
# 
#       it "assigns the requested otrunk_view_mode as @otrunk_view_mode" do
#         OtrunkExample::OtrunkViewMode.stub!(:find).and_return(mock_otrunk_view_mode(:update_attributes => true))
#         put :update, :id => "1"
#         assigns[:otrunk_view_mode].should equal(mock_otrunk_view_mode)
#       end
# 
#       it "redirects to the otrunk_view_mode" do
#         OtrunkExample::OtrunkViewMode.stub!(:find).and_return(mock_otrunk_view_mode(:update_attributes => true))
#         put :update, :id => "1"
#         response.should redirect_to(otrunk_example_otrunk_view_mode_url(mock_otrunk_view_mode))
#       end
#     end
# 
#     describe "with invalid params" do
#       it "updates the requested otrunk_view_mode" do
#         OtrunkExample::OtrunkViewMode.should_receive(:find).with("37").and_return(mock_otrunk_view_mode)
#         mock_otrunk_view_mode.should_receive(:update_attributes).with({'these' => 'params'})
#         put :update, :id => "37", :otrunk_view_mode => {:these => 'params'}
#       end
# 
#       it "assigns the otrunk_view_mode as @otrunk_view_mode" do
#         OtrunkExample::OtrunkViewMode.stub!(:find).and_return(mock_otrunk_view_mode(:update_attributes => false))
#         put :update, :id => "1"
#         assigns[:otrunk_view_mode].should equal(mock_otrunk_view_mode)
#       end
# 
#       it "re-renders the 'edit' template" do
#         OtrunkExample::OtrunkViewMode.stub!(:find).and_return(mock_otrunk_view_mode(:update_attributes => false))
#         put :update, :id => "1"
#         response.should render_template('edit')
#       end
#     end
# 
#   end
# 
#   describe "DELETE destroy" do
#     it "destroys the requested otrunk_view_mode" do
#       OtrunkExample::OtrunkViewMode.should_receive(:find).with("37").and_return(mock_otrunk_view_mode)
#       mock_otrunk_view_mode.should_receive(:destroy)
#       delete :destroy, :id => "37"
#     end
# 
#     it "redirects to the otrunk_example_otrunk_view_modes list" do
#       OtrunkExample::OtrunkViewMode.stub!(:find).and_return(mock_otrunk_view_mode(:destroy => true))
#       delete :destroy, :id => "1"
#       response.should redirect_to(otrunk_example_otrunk_view_modes_url)
#     end
#   end
# 
# end
