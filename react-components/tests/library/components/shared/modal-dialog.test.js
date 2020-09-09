/* globals describe it expect */

import React from 'react'
import Enzyme from 'enzyme'
import Adapter from 'enzyme-adapter-react-16'
import ModalDialog from 'components/shared/modal-dialog'
import { pack } from "../../helpers/pack"

Enzyme.configure({adapter: new Adapter()})

describe('When I try to render a modal dialog', () => {

  it("should render without children", () => {
    const modalDialog = Enzyme.mount(<ModalDialog title="Test Dialog"/>);
    expect(modalDialog.html()).toBe(pack(`
      <div class="modal">
        <div class="background"></div>
        <div class="dialog">
          <div class="title">
            Test Dialog
          </div>
        </div>
      </div>
    `));
  });

  it("should render with children", () => {
    const modalDialog = Enzyme.mount(<ModalDialog title="Test Dialog"><div>children here...</div></ModalDialog>);
    expect(modalDialog.html()).toBe(pack(`
      <div class="modal">
        <div class="background"></div>
        <div class="dialog">
          <div class="title">
            Test Dialog
          </div>
          <div>
            children here...
          </div>
        </div>
      </div>
    `));
  });

})
