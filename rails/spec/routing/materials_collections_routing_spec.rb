require "spec_helper"

describe MaterialsCollectionsController do
  describe "routing" do

    it "routes to #index" do
      expect(get("/materials_collections")).to route_to("materials_collections#index")
    end

    it "routes to #new" do
      expect(get("/materials_collections/new")).to route_to("materials_collections#new")
    end

    it "routes to #show" do
      expect(get("/materials_collections/1")).to route_to("materials_collections#show", :id => "1")
    end

    it "routes to #edit" do
      expect(get("/materials_collections/1/edit")).to route_to("materials_collections#edit", :id => "1")
    end

    it "routes to #create" do
      expect(post("/materials_collections")).to route_to("materials_collections#create")
    end

    it "routes to #update" do
      expect(put("/materials_collections/1")).to route_to("materials_collections#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(delete("/materials_collections/1")).to route_to("materials_collections#destroy", :id => "1")
    end

  end
end
