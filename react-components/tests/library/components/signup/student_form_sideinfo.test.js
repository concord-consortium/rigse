/* globals describe it expect */
import React from 'react'

import Enzyme from 'enzyme'
import Adapter from 'enzyme-adapter-react-16'
import StudentFormSideInfo from 'components/signup/student_form_sideinfo'
import { pack } from "../../helpers/pack"

Enzyme.configure({adapter: new Adapter()})

describe('When I try to render signup student form sideinfo', () => {

  it("should render", () => {
    const sideInfo = Enzyme.mount(<StudentFormSideInfo />);
    expect(sideInfo.html()).toBe(pack(`
      <div>
        <p>
          Enter the class word your teacher gave you. If you don't know what the class word is, ask your teacher.
        </p>
      </div>
    `));
  });

})