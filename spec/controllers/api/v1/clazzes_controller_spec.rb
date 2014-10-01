# encoding: utf-8
require 'spec_helper'

describe API::V1::ClazzesController do
  let(:student1) { Factory(:full_portal_student) }
  let(:student2) { Factory(:full_portal_student) }
  let(:clazz) do
    clazz = Factory(:portal_clazz)
    clazz.students = [student1, student2]
    clazz.save!
    clazz
  end

  describe "GET #show" do
    context "when user is authorized to get class data" do
      before { sign_in student1.user }
      it "returns basic class info" do
        get :show, :id => clazz.id
        expect(response.status).to eq(200)
      end
    end

    context "when user is not authorized to get class data" do
      it "returns error" do
        get :show, :id => clazz.id
        expect(response.status).to eq(401)
      end
    end
  end

end
