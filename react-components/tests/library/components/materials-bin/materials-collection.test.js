/* globals describe it expect */

import React from 'react'
import Enzyme from 'enzyme'
import Adapter from 'enzyme-adapter-react-16'
import MBMaterialsCollection from 'components/materials-bin/materials-collection'
import { pack } from "../../helpers/pack"

const materials = [{
  id: 1,
  name: "material 1",
  icon: {
    url: "http://example.com/icon"
  },
  links: {},
  material_properties: "",
  activities: []
}, {
  id: 2,
  name: "material 2",
  icon: {
    url: "http://example.com/icon"
  },
  links: {},
  material_properties: "",
  activities: []
}]

global.Portal = {
  currentUser: {
    isTeacher: true
  }
};

Enzyme.configure({adapter: new Adapter()})

describe('When I try to render materials-bin materials collection', () => {

  it("should render with default props", () => {
    const materialsCollection = Enzyme.shallow(<MBMaterialsCollection materials={materials} />);
    expect(materialsCollection.html()).toBe(pack(`
      <div class="mb-collection">
        <div class="mb-collection-name"></div>
        <div class="mb-material">
          <span class="mb-material-links"></span>
          <span class="mb-material-name">material 1</span>
        </div>
        <div class="mb-material">
          <span class="mb-material-links"></span>
          <span class="mb-material-name">material 2</span>
        </div>
      </div>
    `));
  });

  it("should render with optional props", () => {
    const materialsCollection = Enzyme.shallow(<MBMaterialsCollection materials={materials} name="Collection" teacherGuideUrl="http://example.com/" />);
    expect(materialsCollection.html()).toBe(pack(`
      <div class="mb-collection">
        <div class="mb-collection-name">Collection</div>
        <a href="http://example.com/" target="_blank">Teacher Guide</a>
        <div class="mb-material">
          <span class="mb-material-links"></span>
          <span class="mb-material-name">material 1</span>
        </div>
        <div class="mb-material">
          <span class="mb-material-links"></span>
          <span class="mb-material-name">material 2</span>
        </div>
      </div>
    `));
  });
})
