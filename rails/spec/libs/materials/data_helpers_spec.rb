require 'spec_helper'

# the DataHelpers is intended to be included in a controller so we test it that way
# it uses a view_context controller method
class DataHelpersTestController < ApplicationController
  include Materials::DataHelpers
end

describe DataHelpersTestController, type: :controller do
  let(:sensor_names) { ["Temperature", "Light"] }
  let(:host) { 'https://test.org' }
  let(:material_a) {
    FactoryBot.create(
      :external_activity,
      sensor_list: sensor_names,
      author_url: host + '/activities/1/edit',
      print_url: host + '/print',
      is_locked: false,
      teacher_copyable: true,
      teacher_resources_url: host + '/teacher-resources',
      teacher_guide_url: host + '/teacher-guide',
      rubric_doc_url: host + '/rubric-doc'
    )
  }
  let(:materials)  { [material_a] }
  let(:material_b) { FactoryBot.create(:external_activity, author_url: '') }
  let(:material_locked) {
    FactoryBot.create(
      :external_activity,
      author_url: host + '/activities/1/edit',
      is_locked: true,
      author_email: 'author2@concord.org'
    )
  }
  let(:material_not_copyable) {
    FactoryBot.create(
      :external_activity,
      author_url: host + '/activities/1/edit',
      is_locked: false,
      teacher_copyable: false,
      author_email: 'author2@concord.org'
    )
  }
  let(:admin_user) { FactoryBot.generate(:admin_user) }
  let(:manager_user) { FactoryBot.generate(:manager_user) }
  let(:author_user1) { FactoryBot.generate(:author_user) }
  let(:author_user2) {
    FactoryBot.create(
      :user,
      :login => 'author2',
      :password => 'password',
      :email => 'author2@concord.org'
    ) }
  let(:teacher_user) { FactoryBot.create(:portal_teacher) }
  let(:guest) { FactoryBot.generate(:anonymous_user) }

  before(:each) do
    Client.create(
      app_id: 'testing-client',
      app_secret: 'xyzzy',
      name: 'testing-client',
      site_url: host
    )
    Tool.create(
      source_type: 'testing-client',
      remote_duplicate_url: host + '/remote_duplicate',
      tool_id: host
    )
  end

  describe "#materials_data" do
    # materials_data is a private method so we need to use send to call it
    subject { controller.send(:materials_data, materials) }

    it "should return an array of materials" do
      expect(subject.length).to eq 1
    end

    it "should return an array of sensor names" do
      # internally it is using tags to store these sensors
      returned_sensors = subject[0][:sensors]
      expect(returned_sensors.length).to eq 2
      expect(returned_sensors).to include(*sensor_names)
    end
  end

  describe "#external_copyable" do
    it "should return false if material does not have an authoring URL" do
      is_copyable = controller.send(:external_copyable, material_b)
      expect(is_copyable).to be(false)
    end

    it "should return true if current user is an admin" do
      sign_in admin_user
      is_copyable = controller.send(:external_copyable, material_a)
      expect(is_copyable).to be(true)
    end

    it "should return true if current user is a manager" do
      sign_in manager_user
      is_copyable = controller.send(:external_copyable, material_a)
      expect(is_copyable).to be(true)
    end

    it "should return false if current user is an author and material is locked" do
      sign_in author_user1
      is_copyable = controller.send(:external_copyable, material_locked)
      expect(is_copyable).to be(false)
    end

    it "should return true if current user is an author and material is not locked" do
      sign_in author_user1
      is_copyable = controller.send(:external_copyable, material_a)
      expect(is_copyable).to be(true)
    end

    it "should return true if current user is the original author of the material" do
      author_user2.confirmed_at = Time.zone.now
      author_user2.add_role('author')
      author_user2.save
      sign_in author_user2
      is_copyable = controller.send(:external_copyable, material_locked)
      expect(is_copyable).to be(true)
    end

    it "should return false if current user is a teacher and material is not marked as copyable by teachers" do
      sign_in teacher_user.user
      is_copyable = controller.send(:external_copyable, material_not_copyable)
      expect(is_copyable).to be(false)
    end

    it "should return false if current user is not an admin or manager, not the original author of the material, and not an author when the material is unlocked even if the material is set to be copyable by teachers" do
      sign_in guest
      is_copyable = controller.send(:external_copyable, material_a)
      expect(is_copyable).to be(false)
    end
  end

  describe "#links_for_material" do
    it "should return values for browse, preview, and print links for an external activity" do
      links = controller.send(:links_for_material, material_a)
      browse = links[:browse]
      preview = links[:preview]
      print = links[:print_url]
      expect(browse[:url]).not_to be_empty
      expect(preview[:url]).not_to be_empty
      expect(print[:url]).not_to be_empty
    end

    it "should return values for edit (portal settings), copy, external edit, external lara edit, and external edit iframe links for an external activity if an admin is logged in" do
      sign_in admin_user
      links = controller.send(:links_for_material, material_a)
      edit = links[:edit]
      external_edit = links[:external_edit]
      external_lara_edit = links[:external_lara_edit]
      external_edit_iframe = links[:external_edit_iframe]
      expect(edit[:url]).not_to be_empty
      expect(external_edit[:url]).not_to be_empty
      expect(external_lara_edit[:url]).not_to be_empty
      expect(external_edit_iframe[:url]).not_to be_empty
    end

    it "should return values for teacher resource, teacher guide and rubric if a teacher is logged in" do
      sign_in teacher_user.user
      links = controller.send(:links_for_material, material_a)
      teacher_resources = links[:teacher_resources]
      teacher_guide = links[:teacher_guide]
      rubric_doc = links[:rubric_doc]
      expect(teacher_resources).not_to be_empty
      expect(teacher_guide).not_to be_empty
      expect(rubric_doc).not_to be_empty
    end

    it "should not return values for teacher resource, teacher guide and rubric to guests" do
      sign_in guest
      links = controller.send(:links_for_material, material_a)
      teacher_resources = links[:teacher_resources]
      teacher_guide = links[:teacher_guide]
      rubric_doc = links[:rubric_doc]
      expect(teacher_resources).to be_nil
      expect(teacher_guide).to be_nil
      expect(rubric_doc).to be_nil
    end
  end

end
