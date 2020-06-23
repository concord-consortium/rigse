/* globals describe it expect */

import React from 'react'
import Enzyme from 'enzyme'
import Adapter from 'enzyme-adapter-react-16'
import MBMaterial from 'components/materials-bin/material'
import { pack } from "../../helpers/pack"

const material = {
  id: 1,
  name: "material 1",
  icon: {
    url: "http://example.com/icon"
  },
  links: {},
  material_properties: "",
  activities: []
};

global.Portal = {
  currentUser: {
    isTeacher: true
  }
};

Enzyme.configure({adapter: new Adapter()})

describe('When I try to render materials-bin material', () => {

  it("should render with default props", () => {
    const _material = Enzyme.shallow(<MBMaterial material={material} />);
    expect(_material.html()).toBe(pack(`
      <div class="mb-material">
        <span class="mb-material-links"></span>
        <span class="mb-material-name">material 1</span>
      </div>
    `));
  });

  // TODO: add more tests...
})

