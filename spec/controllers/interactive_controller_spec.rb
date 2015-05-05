require File.expand_path('../../spec_helper', __FILE__)#include ApplicationHelper


describe InteractivesController do

  let(:name)                { "Interactive 1" }
  let(:description)         { "description of Interactive 1" }
  let(:url)                 { "http://lab.concord.org/embeddable.html#interactives/itsi/energy2d/conduction-wood-metal.json" }
  let(:width)               { "690" }
  let(:height)              { "400" }
  let(:scale)               { "1.0" }
  let(:image_url)           { "http://itsisu.concord.org/share/model_images/10.png" }
  let(:user_id)             { login_admin.id }
  let(:credits)             { "credits of Interactive 1" }
  let(:publication_status)  { "published" }

  let(:test_interactive) {
    test_interactive = Factory.create(:interactive,
      :name => name,
      :description => description,
      :url => url,
      :width => width,
      :height => height,
      :scale => scale,
      :image_url => image_url,
      :user_id => user_id,
      :credits => credits,
      :publication_status => publication_status)
    test_interactive.model_type_list.add("tag1")
    test_interactive.save!
    test_interactive
  } 

  before(:each) do    
    test_interactive
  end

  describe '#create' do
    context "when publication status is provided" do
      it "should create interactive" do
        post :create, {
          :interactive => {
            :name => name, 
            :description => description, 
            :publication_status => publication_status, 
            :url => url, 
            :scale => scale, 
            :width => width, 
            :height => height, 
            :image_url => image_url, 
            :credits => credits
          }
        }

        expect(flash[:notice]).to eq("Interactive was successfully created.")
        assigns(:interactive).publication_status.should be publication_status
        expect(response).to redirect_to(interactive_path(assigns(:interactive)))
      end
    end

    context "when publication status is not provided" do
      it "should create interactive" do
        post :create, {
          :interactive => {
            :name => name, 
            :description => description,
            :url => url, 
            :scale => scale, 
            :width => width, 
            :height => height, 
            :image_url => image_url, 
            :credits => credits
          }
        }
        expect(flash[:notice]).to eq("Interactive was successfully created.")
        assigns(:interactive).publication_status.should == "draft"
        expect(response).to redirect_to(interactive_path(assigns(:interactive)))
      end
    end

    context "taggings" do
      it "should tag the interactive with proper model_type tag" do
        post :create, {
          :interactive => {
            :name => name,
            :description => description,
            :url => url,
            :scale => scale,
            :width => width,
            :height => height,
            :image_url => image_url,
            :credits => credits
          },
          :update_model_types => "true",
          :model_types => ["model_type_1"],
          :update_grade_levels => "true",
          :grade_levels => ["1","5"],
          :update_subject_areas => "true",
          :subject_areas => ["Physical Science"]
        }
        expect(flash[:notice]).to eq("Interactive was successfully created.")
        assigns(:interactive).model_type_list.should match_array(["model_type_1"])
        assigns(:interactive).grade_level_list.should match_array(["1","5"])
        assigns(:interactive).subject_area_list.should match_array(["Physical Science"])
        expect(response).to redirect_to(interactive_path(assigns(:interactive)))
      end
    end
  end

  describe "#update" do 
    it "should change the activity's database record to show submitted data" do
      test_interactive
      existing_interactives = Interactive.count
      post :update, { 
          :interactive=>{
            :name => name, 
            :description => description, 
            :publication_status => publication_status, 
            :url => url, 
            :scale => scale, 
            :width => width, 
            :height => height, 
            :image_url => image_url, 
            :credits => credits}, 
          :update_grade_levels =>"true", 
          :grade_levels =>["1", "5"], 
          :update_subject_areas =>"true", 
          :subject_areas =>["Physical Science"], 
          :update_model_types =>"true", 
          :model_types =>["model_type_2"], 
          :id => test_interactive.id
        }

      expect(Interactive.count).to eq(existing_interactives)

      updated = Interactive.find(test_interactive.id)
      updated.model_type_list.should match_array(["model_type_2"])
      expect(flash[:notice]).to eq("Interactive was successfully updated.")
    end
  end

  describe "#export_model_library" do 
    it "should export a json file" do
      get :export_model_library
      response.header["Content-Type"].should == "application/json"
      response.header["Content-Disposition"].should == "attachment; filename=\"portal_interactives_library.json\""
    end
  end

  describe "#import_model_library" do
    import_json = File.new(Rails.root + 'spec/import_examples/portal_interactives_library.json', :symbolize_names => true)
    let(:params1) do
      {
         import:ActionDispatch::Http::UploadedFile.new(tempfile: import_json, filename: File.basename(import_json), content_type: "application/json")         
      }
    end    
    it "should import all the models from a json" do
      import_hash = JSON.parse(File.read(import_json))
      model_library_count = import_hash["models"].length
      existing_interactives_count = Interactive.count
      xhr :post, :import_model_library, params1
      new_interactives_count = Interactive.count
      expect(new_interactives_count - existing_interactives_count).to eq(model_library_count)
    end
  end
end
