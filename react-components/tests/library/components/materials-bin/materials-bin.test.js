/* globals describe it expect */

import React from 'react'
import Enzyme from 'enzyme'
import Adapter from 'enzyme-adapter-react-16'
import MaterialsBin from 'components/materials-bin/materials-bin'
import { pack } from "../../helpers/pack"
import {mockJquery} from "../../helpers/mock-jquery"

var materials = [
  {
    category: "Cat A",
    className: "custom-category-class",
    children: [
      {
        category: "Cat A1",
        children: [
          {
            collections: [
              {id: "Collection 2"}
             ]
          }
        ]
      },
      {
        category: "Cat A2",
        children: []
      }
    ]
  },
  {
    category: "Cat B",
    children: [
      {
        category: "Cat B1",
        children: [
          {
            collections: [
              {id: "Collection 3"}
             ]
          }
        ]
      },
      {
        category: "Cat B2",
        children: []
      }
    ]
  },
  {
    category: "Cat C",
    loginRequired: true,
    children: [
      {
        ownMaterials: true
      }
    ]
  },
  {
    category: "Cat D",
    children: [
      {
        materialsByAuthor: true
      }
    ]
  }
];

global.Portal = {
  API_V1: {
    MATERIALS_OWN: "https://example.com/"
  },
  currentUser: {
    isTeacher: true
  }
};

const mockedJQuery = () => ({
  on: (message) => {}
});
mockedJQuery.trim = (s) => s.trim()

Enzyme.configure({adapter: new Adapter()})

describe('When I try to render materials-bin', () => {

  mockJquery(mockedJQuery)

  it("should render with default props", () => {
    const materialsBin = Enzyme.shallow(<MaterialsBin materials={materials} />);
    expect(materialsBin.html()).toBe(pack(`
      <div class="materials-bin">
        <div class="mb-column">
          <div class="mb-cell mb-category mb-clickable custom-category-class  mb-selected">Cat A</div>
          <div class="mb-cell mb-category mb-clickable   ">Cat B</div>
          <div class="mb-cell mb-category mb-clickable   ">Cat C</div>
          <div class="mb-cell mb-category mb-clickable   ">Cat D</div>
        </div>
        <div class="mb-column">
          <div class="mb-cell mb-category mb-clickable   mb-selected">Cat A1</div>
          <div class="mb-cell mb-category mb-clickable   ">Cat A2</div>
          <div class="mb-cell mb-category mb-clickable  mb-hidden ">Cat B1</div>
          <div class="mb-cell mb-category mb-clickable  mb-hidden ">Cat B2</div>
          <div class="mb-cell mb-hidden">
            <div>Loading...</div>
          </div>
          <div class="mb-cell mb-hidden">
            <div>Loading...</div>
          </div>
        </div>
        <div class="mb-column">
          <div class="mb-collection">
            <div class="mb-collection-name"></div>
          </div>
          <div class="mb-collection">
            <div class="mb-collection-name"></div>
          </div>
        </div>
      </div>
    `));
  });

  it("should handle clicking of categories", () => {
    const materialsBin = Enzyme.mount(<MaterialsBin materials={materials} />);
    const categoryB = materialsBin.find({slug: "cat-b"});
    categoryB.simulate("click")
    materialsBin.instance().checkHash()
    materialsBin.update();
    expect(materialsBin.html()).toBe(pack(`
      <div class="materials-bin">
        <div class="mb-column">
          <div class="mb-cell mb-category mb-clickable custom-category-class  ">Cat A</div>
          <div class="mb-cell mb-category mb-clickable   mb-selected">Cat B</div>
          <div class="mb-cell mb-category mb-clickable   ">Cat C</div>
          <div class="mb-cell mb-category mb-clickable   ">Cat D</div>
        </div>
        <div class="mb-column">
          <div class="mb-cell mb-category mb-clickable  mb-hidden ">Cat A1</div>
          <div class="mb-cell mb-category mb-clickable  mb-hidden ">Cat A2</div>
          <div class="mb-cell mb-category mb-clickable   ">Cat B1</div>
          <div class="mb-cell mb-category mb-clickable   ">Cat B2</div>
          <div class="mb-cell mb-hidden">
            <div>Loading...</div>
          </div>
          <div class="mb-cell mb-hidden">
            <div>Loading...</div>
          </div>
        </div>
        <div class="mb-column">
          <div class="mb-collection">
            <div class="mb-collection-name"></div>
          </div>
          <div class="mb-collection">
            <div class="mb-collection-name"></div>
          </div>
        </div>
      </div>
    `));
  });
})
