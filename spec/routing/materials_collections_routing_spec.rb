require "spec_helper"

describe MaterialsCollectionsController do
  describe "routing" do

    it "routes to #index" do
      get("/materials_collections").should route_to("materials_collections#index")
    end

    it "routes to #new" do
      get("/materials_collections/new").should route_to("materials_collections#new")
    end

    it "routes to #show" do
      get("/materials_collections/1").should route_to("materials_collections#show", :id => "1")
    end

    it "routes to #edit" do
      get("/materials_collections/1/edit").should route_to("materials_collections#edit", :id => "1")
    end

    it "routes to #create" do
      post("/materials_collections").should route_to("materials_collections#create")
    end

    it "routes to #update" do
      put("/materials_collections/1").should route_to("materials_collections#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/materials_collections/1").should route_to("materials_collections#destroy", :id => "1")
    end

    it "routes to #sort_materials" do
      post("/materials_collections/1/sort_materials").should route_to("materials_collections#sort_materials", :id => "1")
    end

    it "routes to #remove_material" do
      post("/materials_collections/1/remove_material").should route_to("materials_collections#remove_material", :id => "1")
    end

  end
end
