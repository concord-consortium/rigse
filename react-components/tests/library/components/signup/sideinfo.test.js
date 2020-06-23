/* globals describe it expect */
import React from 'react'

import Enzyme from 'enzyme'
import Adapter from 'enzyme-adapter-react-16'
import SideInfo from 'components/signup/sideinfo'
import { pack } from "../../helpers/pack"

Enzyme.configure({adapter: new Adapter()})

describe('When I try to render signup side info', () => {

  it("should render", () => {
    const sideInfo = Enzyme.mount(<SideInfo />);
    expect(sideInfo.html()).toBe(pack(`
      <div>
        <div class="side-info-header">
          Why sign up?
          <p>
            It's free and you get access to several key features:
          </p>
          <ul>
            <li>Create classes for your students and assign them activities</li>
            <li>Save student work</li>
            <li>Track student progress through activities</li>
          </ul>
        </div>
      </div>
    `));
  });

})