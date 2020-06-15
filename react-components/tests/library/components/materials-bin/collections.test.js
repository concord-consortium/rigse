/* globals describe it expect */

import React from 'react'
import Enzyme from 'enzyme'
import Adapter from 'enzyme-adapter-react-16'
import MBCollections from 'components/materials-bin/collections'
import { pack } from "../../helpers/pack"
import {mockJqueryAjaxSuccess} from "../../helpers/mock-jquery"

const collections = [{
  name: "Collection Name",
  materials: [{
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

describe('When I try to render materials-bin collections', () => {

  mockJqueryAjaxSuccess(collections)

  it("should render with default props", () => {
    const _collections = Enzyme.mount(<MBCollections />);
    expect(_collections.html()).toBe(pack(`
      <div class="mb-cell mb-hidden"><div>Loading...</div></div>
    `));
  });

  it("should render with visible props", () => {
    const _collections = Enzyme.mount(<MBCollections visible={true} collections={[{id: 1}, {id: 2}]} />);
    expect(_collections.html()).toBe(pack(`
      <div class="mb-cell ">
        <div class="mb-collection">
          <div class="mb-collection-name">Collection Name</div>
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
    `));
  });

})
