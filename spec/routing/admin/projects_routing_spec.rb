require "spec_helper"

describe Admin::ProjectsController do
  describe "routing" do

    it "routes to #landing_page" do
      expect(get("/project-slug")).to route_to("admin/projects#landing_page", :landing_page_slug => "project-slug")
    end

    it "routes to #index" do
     expect(get("/admin/projects")).to route_to("admin/projects#index")
    end

    it "routes to #new" do
      expect(get("/admin/projects/new")).to route_to("admin/projects#new")
    end

    it "routes to #show" do
      expect(get("/admin/projects/1")).to route_to("admin/projects#show", :id => "1")
    end

    it "routes to #edit" do
      expect(get("/admin/projects/1/edit")).to route_to("admin/projects#edit", :id => "1")
    end

    it "routes to #create" do
      expect(post("/admin/projects")).to route_to("admin/projects#create")
    end

    it "routes to #update" do
      expect(put("/admin/projects/1")).to route_to("admin/projects#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(delete("/admin/projects/1")).to route_to("admin/projects#destroy", :id => "1")
    end
  end
end
