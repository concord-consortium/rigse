require 'spec_helper'

describe Portal::PermissionForm do
  let(:permission_form_args) { {name: "permission_a"} }
  let(:permission_form) { FactoryGirl.create(:permission_form, permission_form_args)}

  it 'should exist' do
    expect(permission_form).to be_a(Portal::PermissionForm)
  end

  it 'should have a name' do
    expect(permission_form.name).to match "permission_a"
  end

  describe "#fullname" do
    let(:project) { FactoryGirl.create(:admin_project, name: "project a") }
    let(:permission_form_args) do
      {
          name: "permission_a",
          project: project
      }
    end

    it "should include the projects name" do
      expect(permission_form.fullname).to match "project a"
    end

  end
end
