/* globals describe it expect */
import React from 'react'
import Enzyme from 'enzyme'
import Adapter from 'enzyme-adapter-react-16'
import SMaterialBody from 'components/search/material-body'
import { pack } from "../../helpers/pack"

Enzyme.configure({adapter: new Adapter()})

describe('When I try to render search material bodies', () => {

  it("should render singular values", () => {
    const material = {
      class_count: 1,
      sensors: ["sensor"]
    }
    const materialBody = Enzyme.shallow(<SMaterialBody material={material} />);
    expect(materialBody.html()).toBe(pack(`
      <div class="material_body">
        <div>
          <i>Used in 1 class.</i>
        </div>
        <div class="required_equipment_container">
          <span>Required sensor(s):</span>
          <span style="font-weight:bold">sensor</span>
        </div>
      </div>
    `));
  });

  it("should render non-singular values", () => {
    const material = {
      class_count: 2,
      sensors: ["sensor1", "sensor2"]
    }
    const materialBody = Enzyme.shallow(<SMaterialBody material={material} />);
    expect(materialBody.html()).toBe(pack(`
      <div class="material_body">
        <div>
          <i>Used in 2 classes.</i>
        </div>
        <div class="required_equipment_container">
          <span>Required sensor(s):</span>
          <span style="font-weight:bold">sensor1, sensor2</span>
        </div>
      </div>
    `));
  });

})