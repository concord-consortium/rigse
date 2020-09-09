/* globals describe it expect */

import React from 'react'
import Enzyme from 'enzyme'
import Adapter from 'enzyme-adapter-react-16'
import Modal from 'components/shared/modal'
import { pack } from "../../helpers/pack"

Enzyme.configure({adapter: new Adapter()})

describe('When I try to render a modal', () => {

  it("should render without children", () => {
    const modal = Enzyme.mount(<Modal />);
    expect(modal.html()).toBe(pack(`
      <div class="modal">
        <div class="background"></div>
      </div>
    `));
  });

  it("should render with children", () => {
    const modal = Enzyme.mount(<Modal><div>children here...</div></Modal>);
    expect(modal.html()).toBe(pack(`
      <div class="modal">
        <div class="background"></div>
        <div>
          children here...
        </div>
      </div>
    `));
  });

})
