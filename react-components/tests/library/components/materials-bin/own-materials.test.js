/* globals describe it expect */

import React from 'react'
import Enzyme from 'enzyme'
import Adapter from 'enzyme-adapter-react-16'
import MBOwnMaterials from 'components/materials-bin/own-materials'
import { pack } from "../../helpers/pack"
import {mockJqueryAjaxSuccess} from "../../helpers/mock-jquery"

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
  API_V1: {
    MATERIALS_BIN_UNOFFICIAL_MATERIALS: "http://example.com"
  },
  currentUser: {
    isTeacher: false
  }
};

Enzyme.configure({adapter: new Adapter()})

describe('When I try to render materials-bin own materials', () => {

  mockJqueryAjaxSuccess(materials)

  it("should render with default props", () => {
    const ownMaterials = Enzyme.mount(<MBOwnMaterials userId={1} />);
    expect(ownMaterials.html()).toBe(pack(`
      <div class="mb-cell mb-hidden"><div>Loading...</div></div>
    `));
  });

  it("should render with optional props", () => {
    const ownMaterials = Enzyme.mount(<MBOwnMaterials userId={1} name="Collection Name" visible={true} />);
    expect(ownMaterials.html()).toBe(pack(`
      <div class="mb-cell ">
        <section class="mb-collection">
          <header>
            <h3 class="mb-collection-name">My activities</h3>
          </header>
          <div class="mb-material">
            <div class="mb-material-thumbnail">
              <img alt="material 1" src="http://example.com/icon">
            </div>
            <div class="mb-material-text">
              <h4 class="mb-material-name">material 1</h4>
              <div class="mb-material-links"></div>
            </div>
          </div>
          <div class="mb-material">
            <div class="mb-material-thumbnail">
              <img alt="material 2" src="http://example.com/icon">
            </div>
            <div class="mb-material-text">
              <h4 class="mb-material-name">material 2</h4>
              <div class="mb-material-links"></div>
            </div>
          </div>
        </section>
      </div>
    `));
  });

  // TODO: add test for archiveSingle()

})
