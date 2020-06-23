/* globals describe it expect */

import React from 'react'
import Enzyme from 'enzyme'
import Adapter from 'enzyme-adapter-react-16'
import MBMaterialsCategory from 'components/materials-bin/materials-category'
import { pack } from "../../helpers/pack"

Enzyme.configure({adapter: new Adapter()})

describe('When I try to render materials-bin materials category', () => {

  it("should render with default props", () => {
    const materialsCategory = Enzyme.shallow(<MBMaterialsCategory><div>children...</div></MBMaterialsCategory>);
    expect(materialsCategory.html()).toBe(pack(`
      <div class="mb-cell mb-category mb-clickable  mb-hidden ">
        <div>children...</div>
      </div>
    `));
  });

  it("should render with optional props", () => {
    const handleClick = jest.fn()
    const materialsCategory = Enzyme.shallow(<MBMaterialsCategory customClass="foo" visible={true} selected={true} handleClick={handleClick}><div>children...</div></MBMaterialsCategory>);
    expect(materialsCategory.html()).toBe(pack(`
      <div class="mb-cell mb-category mb-clickable foo  mb-selected">
        <div>children...</div>
      </div>
    `));

    expect(handleClick).not.toHaveBeenCalled()
    const toggleButton = materialsCategory.find(".mb-cell");
    toggleButton.simulate("click")
    expect(handleClick).toHaveBeenCalled()
  });

})
