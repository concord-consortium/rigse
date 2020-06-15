/* globals describe it expect */

import React from 'react'
import Enzyme from 'enzyme'
import Adapter from 'enzyme-adapter-react-16'
import MBUserMaterials from 'components/materials-bin/user-materials'
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

describe('When I try to render materials-bin user materials', () => {

  mockJqueryAjaxSuccess(materials)

  it("should render with default props", () => {
    const userMaterials = Enzyme.shallow(<MBUserMaterials userId={1} />);
    expect(userMaterials.html()).toBe(pack(`
      <div>
        <div class="mb-collection-name mb-clickable"><span class="mb-toggle-symbol">+</span> </div>
        <div class="mb-hidden">
          <div>Loading...</div>
        </div>
      </div>
    `));
  });

  it("should render with optional props", () => {
    const userMaterials = Enzyme.shallow(<MBUserMaterials userId={1} name="Collection Name" />);
    expect(userMaterials.html()).toBe(pack(`
      <div>
        <div class="mb-collection-name mb-clickable"><span class="mb-toggle-symbol">+</span> Collection Name</div>
        <div class="mb-hidden">
          <div>Loading...</div>
        </div>
      </div>
    `));
  });

  it("should allow toggling which loads data", () => {
    const userMaterials = Enzyme.mount(<MBUserMaterials userId={1} name="Collection Name" />);
    const toggleButton = userMaterials.find(".mb-collection-name");
    toggleButton.simulate("click")
    userMaterials.update()
    expect(userMaterials.html()).toBe(pack(`
      <div>
        <div class="mb-collection-name mb-clickable">
          <span class="mb-toggle-symbol">-</span> Collection Name
        </div>
        <div class="">
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
      </div>
      </div>
    `));
  });

  // TODO: add test for archiveSingle()

})
