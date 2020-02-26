require 'spec_helper'

# the DataHelpers is intended to be included in a controller so we test it that way
# it uses a view_context controller method
class DataHelpersTestController < ApplicationController
  include Materials::DataHelpers
end

describe DataHelpersTestController, type: :controller do
  let(:sensor_names) { ["Temperature", "Light"] }
  let(:material_a) { FactoryBot.create(:external_activity, sensor_list: sensor_names, launch_url: 'https://test.org/', is_locked: false) }
  let(:materials)  { [material_a] }
  let(:material_b) { FactoryBot.create(:external_activity, launch_url: '') }
  let(:material_locked) { FactoryBot.create(:external_activity, launch_url: 'https://test.org/', is_locked: true, author_email: 'author2@concord.org') }
  let(:admin_user) { FactoryBot.generate(:admin_user) }
  let(:manager_user) { FactoryBot.generate(:manager_user) }
  let(:author_user1) { FactoryBot.generate(:author_user) }
  let(:author_user2) { FactoryBot.create(:user, :login => 'author2', :password => 'password', :email => 'author2@concord.org') }
  let(:guest) { FactoryBot.generate(:anonymous_user) }

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
    it "should return false if material does not have a launch URL" do
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

    it "should return false if current user is not an admin or manager, not the original author of the material, and not an author when the material is unlocked" do
      sign_in guest
      is_copyable = controller.send(:external_copyable, material_a)
      expect(is_copyable).to be(false)
    end
  end

  describe "#links_for_material" do
    it "should return values for browse, preview, and ... links for an external activity" do
      links = controller.send(:links_for_material, material_a)
      browse = links[:browse]
      preview = links[:preview]
      expect(browse[:url]).not_to be_empty
      expect(preview[:url]).not_to be_empty
    end
  end

end
