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
      <section class="mb-collection">
        <header>
          <h3 class="mb-collection-name"></h3>
        </header>
        <div class="mb-material">
          <div class="mb-material-thumbnail">
            <img alt="material 1" src="http://example.com/icon"/>
          </div>
          <div class="mb-material-text">
            <h4 class="mb-material-name">material 1</h4>
            <div class="mb-material-links"></div>
          </div>
        </div>
        <div class="mb-material">
          <div class="mb-material-thumbnail">
            <img alt="material 2" src="http://example.com/icon"/>
          </div>
          <div class="mb-material-text">
            <h4 class="mb-material-name">material 2</h4>
            <div class="mb-material-links"></div>
          </div>
        </div>
      </section>
    `));
  });

  it("should render with optional props", () => {
    const materialsCollection = Enzyme.shallow(<MBMaterialsCollection materials={materials} name="Collection" teacherGuideUrl="http://example.com/" />);
    expect(materialsCollection.html()).toBe(pack(`
      <section class="mb-collection">
        <header>
          <h3 class="mb-collection-name">Collection</h3>
          <a href="http://example.com/" target="_blank">Teacher Guide</a>
        </header>
        <div class="mb-material">
          <div class="mb-material-thumbnail">
            <img alt="material 1" src="http://example.com/icon"/>
          </div>
          <div class="mb-material-text">
            <h4 class="mb-material-name">material 1</h4>
            <div class="mb-material-links"></div>
          </div>
        </div>
        <div class="mb-material">
          <div class="mb-material-thumbnail">
            <img alt="material 2" src="http://example.com/icon"/>
          </div>
          <div class="mb-material-text">
            <h4 class="mb-material-name">material 2</h4>
            <div class="mb-material-links"></div>
          </div>
        </div>
      </section>
    `));
  });
})
