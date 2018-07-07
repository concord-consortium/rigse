require 'spec_helper'

# the DataHelpers is intended to be included in a controller so we test it that way
# it uses a view_context controller method
class DataHelpersTestController < ApplicationController
  include Materials::DataHelpers
end

describe DataHelpersTestController, type: :controller do
  let(:sensor_names) { ["Temperature", "Light"] }
  let(:material_a) { Factory.create(:external_activity, sensor_list: sensor_names) }
  let(:materials)  { [material_a] }

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

end
