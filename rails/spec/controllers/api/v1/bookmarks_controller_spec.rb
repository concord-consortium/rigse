require 'spec_helper'

describe API::V1::BookmarksController do
  let(:admin_settings) { FactoryBot.create(:admin_settings, :enabled_bookmark_types => ["Portal::GenericBookmark"]) }
  let(:mock_school)    { FactoryBot.create(:portal_school) }
  let(:teacher_user1)  { FactoryBot.create(:confirmed_user, login: "teacher_user1") }
  let(:teacher_user2)  { FactoryBot.create(:confirmed_user, login: "teacher_user2") }
  let(:teacher1)       { FactoryBot.create(:portal_teacher, user: teacher_user1, schools: [mock_school]) }
  let(:teacher2)       { FactoryBot.create(:portal_teacher, user: teacher_user2, schools: [mock_school]) }
  let(:clazz1)         { FactoryBot.create(:portal_clazz, teachers: [teacher1]) }
  let(:clazz2)         { FactoryBot.create(:portal_clazz, teachers: [teacher2]) }

  describe "As a non-teacher of the class" do
    before(:each) do
      sign_in teacher_user2
    end

    describe "each api endpoint" do
      [:create, :update, :destroy, :sort].each do |method|
        it("should fail without a clazz_id") do
          post method
          expect(response.status).to eql(400)
          expect(response.body).to eql('{"success":false,"response_type":"ERROR","message":"Missing clazz_id param"}')
        end

        it("should fail with an invalid clazz_id") do
          post method, params: { clazz_id: clazz1.id + 1 }
          expect(response.status).to eql(400)
          expect(response.body).to eql('{"success":false,"response_type":"ERROR","message":"Invalid clazz_id param"}')
        end

        it("should fail with a clazz_id I don't own") do
          post method, params: { clazz_id: clazz1.id }
          expect(response.status).to eql(400)
          expect(response.body).to eql('{"success":false,"response_type":"ERROR","message":"You are not authorized to edit bookmarks for this class"}')
        end
      end
    end
  end

  describe "As a teacher of the class" do
    before(:each) do
      admin_settings
      sign_in teacher_user1
    end

    describe "each api endpoint" do
      [:create, :update, :destroy, :sort].each do |method|
        it("should fail without a clazz_id") do
          post method
          expect(response.status).to eql(400)
          expect(response.body).to eql('{"success":false,"response_type":"ERROR","message":"Missing clazz_id param"}')
        end

        it("should fail with an invalid clazz_id") do
          post method, params: { clazz_id: clazz1.id + 1 }
          expect(response.status).to eql(400)
          expect(response.body).to eql('{"success":false,"response_type":"ERROR","message":"Invalid clazz_id param"}')
        end
      end
    end

    describe "create" do
      it "should use default field values" do
        post :create, params: { clazz_id: clazz1.id }
        expect(response.status).to eql(200)
        result = JSON.parse response.body
        expect(result["data"]["name"]).to eql "My bookmark"
        expect(result["data"]["url"]).to eql "http://concord.org"
        expect(result["data"]["is_visible"]).to eql true
      end

      it "should use passed values" do
        post :create, params: { clazz_id: clazz1.id, name: "Test", url: "http://example.com" }
        expect(response.status).to eql(200)
        result = JSON.parse response.body
        expect(result["data"]["name"]).to eql "Test"
        expect(result["data"]["url"]).to eql "http://example.com"
        expect(result["data"]["is_visible"]).to eql true
      end
    end

    describe "bookmarks" do
      let(:bookmark1) { FactoryBot.create(:generic_bookmark, name: "Example Bookmark 1", url: "http://example.com/example1", user: teacher_user1, clazz: clazz1) }
      let(:bookmark2) { FactoryBot.create(:generic_bookmark, name: "Example Bookmark 2", url: "http://example.com/example2", user: teacher_user2, clazz: clazz2) }
      let(:bookmark3) { FactoryBot.create(:generic_bookmark, name: "Example Bookmark 3", url: "http://example.com/example3", user: teacher_user1, clazz: clazz2) }

      describe "update" do
        it "should fail with an invalid bookmark id" do
          post :update, params: { clazz_id: clazz1.id, id: bookmark2.id + 1 }
          expect(response.status).to eql(400)
          expect(response.body).to eql('{"success":false,"response_type":"ERROR","message":"Invalid bookmark id"}')
        end

        it "should fail when the teacher doesn't own the bookmark" do
          post :update, params: { clazz_id: clazz1.id, id: bookmark2.id }
          expect(response.status).to eql(400)
          expect(response.body).to eql('{"success":false,"response_type":"ERROR","message":"You are not authorized to update the bookmark"}')
        end

        it "should succeed when the teacher owns the bookmark" do
          post :update, params: { clazz_id: clazz1.id, id: bookmark1.id, name: 'Updated name', url: 'http://updated.now', is_visible: false }
          expect(response.status).to eql(200)
          result = JSON.parse response.body
          expect(result["data"]["name"]).to eql "Updated name"
          expect(result["data"]["url"]).to eql "http://updated.now"
          expect(result["data"]["is_visible"]).to eql false
        end
      end

      describe "destroy" do
        it "should fail with an invalid bookmark id" do
          post :destroy, params: { clazz_id: clazz1.id, id: bookmark2.id + 1 }
          expect(response.status).to eql(400)
          expect(response.body).to eql('{"success":false,"response_type":"ERROR","message":"Invalid bookmark id"}')
        end

        it "should fail when the teacher doesn't own the bookmark" do
          post :destroy, params: { clazz_id: clazz1.id, id: bookmark2.id }
          expect(response.status).to eql(400)
          expect(response.body).to eql('{"success":false,"response_type":"ERROR","message":"You are not authorized to delete the bookmark"}')
        end

        it "should succeed when the teacher owns the bookmark" do
          post :destroy, params: { clazz_id: clazz1.id, id: bookmark1.id }
          expect(response.status).to eql(200)
          expect(response.body).to eql('{"success":true}')
        end
      end

      describe "sort" do
        it "should fail without ids" do
          post :sort, params: { clazz_id: clazz1.id }
          expect(response.status).to eql(400)
          expect(response.body).to eql('{"success":false,"response_type":"ERROR","message":"Missing ids parameter"}')
        end

        it "should succeed with ids" do
          post :sort, params: { clazz_id: clazz1.id, ids: [bookmark3.id, bookmark1.id] }
          expect(response.status).to eql(200)
          expect(response.body).to eql('{"success":true}')
        end
      end
    end
  end

end
