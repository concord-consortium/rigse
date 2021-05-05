require 'spec_helper'

describe API::V1::MaterialsCollectionsController do
  let(:non_admin) { FactoryBot.create(:confirmed_user) }
  let(:admin)     { FactoryBot.generate(:admin_user) }

  describe "As a non-admin" do
    before(:each) do
      sign_in non_admin
    end

    describe "each api endpoint" do
      [:sort_materials, :remove_material].each do |method|
        it("should fail") do
          post method, {id: 1}
          expect(response.status).to eql(403)
          expect(response.body).to eql('{"success":false,"message":"Not authorized"}')
        end
      end
    end
  end

  describe "As an admin" do
    let (:collection) { FactoryBot.create(:materials_collection_with_items) }

    before(:each) do
      sign_in admin
    end

    describe "sort_materials" do
      it "should fail with a valid id" do
        post :sort_materials, {id: 0}
        expect(response.status).to eql(404)
      end

      it "should fail without item ids" do
        post :sort_materials, params: { id: collection.id }
        expect(response.status).to eql(400)
        expect(response.body).to eql('{"success":false,"response_type":"ERROR","message":"Missing item_ids parameter"}')
      end

      it "should succeed" do
        # generate randomly sorted ids
        randomized_item_ids = collection.materials_collection_items.map{|mci| mci.id}.shuffle
        post :sort_materials, params: { id: collection.id, item_ids: randomized_item_ids }
        expect(response.status).to eql(200)
        expect(response.body).to eql('{"success":true}')

        # ensure the randomly sorted ids were saved
        collection.materials_collection_items.reload
        ids = collection.materials_collection_items.map{|mci| mci.id}
        expect(ids).to eql(randomized_item_ids)
      end
    end

    describe "remove_material" do
      it "should fail with an invalid id" do
        post :remove_material, {id: 0}
        expect(response.status).to eql(404)
      end

      it "should fail without an item id" do
        post :remove_material, params: { id: collection.id }
        expect(response.status).to eql(400)
        expect(response.body).to eql('{"success":false,"response_type":"ERROR","message":"Missing item_id parameter"}')
      end

      it "should fail with an invalid item id" do
        post :remove_material, params: { id: collection.id, item_id: 0 }
        expect(response.status).to eql(400)
        expect(response.body).to eql('{"success":false,"response_type":"ERROR","message":"Invalid item id: 0"}')
      end

      it "should succeed" do
        item = collection.materials_collection_items[0]
        length_before_delete = collection.materials_collection_items.length

        post :remove_material, params: { id: collection.id, item_id: item.id }
        expect(response.status).to eql(200)
        expect(response.body).to eql('{"success":true}')

        collection.materials_collection_items.reload
        expect(collection.materials_collection_items.length).to eq(length_before_delete - 1)
      end
    end
  end

end
