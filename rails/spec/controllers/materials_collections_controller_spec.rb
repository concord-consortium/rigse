require 'spec_helper'

# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to specify the controller code that
# was generated by Rails when you ran the scaffold generator.
#
# It assumes that the implementation code is generated by the rails scaffold
# generator.  If you are using any extension libraries to generate different
# controller code, this generated spec may or may not pass.
#
# It only uses APIs available in rails and/or rspec-rails.  There are a number
# of tools you can use to make these specs even more expressive, but we're
# sticking to rails and rspec-rails APIs to keep things simple and stable.
#
# Compared to earlier versions of this generator, there is very limited use of
# stubs and message expectations in this spec.  Stubs are only used when there
# is no simpler way to get a handle on the object needed for the example.
# Message expectations are only used when there is no simpler way to specify
# that an instance is receiving a specific message.

describe MaterialsCollectionsController do
  before(:each) do
    @admin_user = FactoryBot.generate(:admin_user)
    allow(controller).to receive(:current_visitor).and_return(@admin_user)

    login_admin
  end

  let(:materials_collection) { FactoryBot.create(:materials_collection) }
  let(:valid_attributes)     { { name: "Some name", description: "Some description" } }

  describe "GET index" do
    it "assigns all materials_collections as @materials_collections" do
      materials_collection
      get :index, {}
      expect(assigns(:materials_collections).to_a).to eq([materials_collection])
    end
  end

  describe "GET show" do
    it "assigns the requested materials_collection as @materials_collection" do
      get :show, {:id => materials_collection.to_param}
      expect(assigns(:materials_collection)).to eq(materials_collection)
    end
  end

  describe "GET new" do
    it "assigns a new materials_collection as @materials_collection" do
      get :new, {}
      expect(assigns(:materials_collection)).to be_a_new(MaterialsCollection)
    end
  end

  describe "GET edit" do
    it "assigns the requested materials_collection as @materials_collection" do
      get :edit, {:id => materials_collection.to_param}
      expect(assigns(:materials_collection)).to eq(materials_collection)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new MaterialsCollection" do
        expect {
          post :create, {:materials_collection => valid_attributes}
        }.to change(MaterialsCollection, :count).by(1)
      end


      it "assigns a newly created materials_collection as @materials_collection" do
        post :create, {:materials_collection => valid_attributes}
        expect(assigns(:materials_collection)).to be_a(MaterialsCollection)
        expect(assigns(:materials_collection)).to be_persisted
      end

      it "redirects to the materials_collections index" do
        post :create, {:materials_collection => valid_attributes}
        expect(response).to redirect_to(materials_collections_url)
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved materials_collection as @materials_collection" do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(MaterialsCollection).to receive(:save).and_return(false)
        post :create, {:materials_collection => valid_attributes}
        expect(assigns(:materials_collection)).to be_a(MaterialsCollection)
        expect(assigns(:materials_collection)).not_to be_persisted
        expect(assigns(:materials_collection)).to be_a_new(MaterialsCollection)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(MaterialsCollection).to receive(:save).and_return(false)
        post :create, {:materials_collection => valid_attributes}
        expect(response).to render_template(:new)
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested materials_collection" do
        # Assuming there are no other materials_collections in the database, this
        # specifies that the MaterialsCollection created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        expect_any_instance_of(MaterialsCollection).to receive(:update_attributes).with({'name' => 'new name'})
        put :update, {:id => materials_collection.to_param, :materials_collection => {'name' => 'new name'}}
      end

      it "assigns the requested materials_collection as @materials_collection" do
        put :update, {:id => materials_collection.to_param, :materials_collection => valid_attributes}
        expect(assigns(:materials_collection)).to eq(materials_collection)
      end

      it "redirects to the materials_collection" do
        put :update, {:id => materials_collection.to_param, :materials_collection => valid_attributes}
        expect(response).to redirect_to(materials_collection)
      end
    end

    describe "with invalid params" do
      it "assigns the materials_collection as @materials_collection" do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(MaterialsCollection).to receive(:save).and_return(false)
        put :update, {:id => materials_collection.to_param, :materials_collection => valid_attributes}
        expect(assigns(:materials_collection)).to eq(materials_collection)
      end

      it "re-renders the 'edit' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(MaterialsCollection).to receive(:save).and_return(false)
        put :update, {:id => materials_collection.to_param, :materials_collection => valid_attributes}
        expect(response).to render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested materials_collection" do
      materials_collection
      expect {
        delete :destroy, {:id => materials_collection.to_param}
      }.to change(MaterialsCollection, :count).by(-1)
    end

    it "redirects to the materials_collections list" do
      delete :destroy, {:id => materials_collection.to_param}
      expect(response).to redirect_to(materials_collections_url)
    end
  end

  describe "POST sort_materials" do
    it 'sorts materials appropriately' do
      collection =  FactoryBot.create(:materials_collection_with_items)
      current_order = collection.materials_collection_items.map {|i| i.id }.dup
      shuffled_order = current_order.shuffle
      post :sort_materials, { :id => collection.id, "materials_materials_collection_#{collection.id}" => shuffled_order }
      new_order = MaterialsCollectionItem.order(:position).where(materials_collection_id: collection.id).map(&:id)
      expect(response.status).to eq(200)
      expect(new_order).to eq(shuffled_order)
    end
  end
end
