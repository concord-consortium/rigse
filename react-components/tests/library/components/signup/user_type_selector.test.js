/* globals describe it expect */
import React from 'react'
import Enzyme from 'enzyme'
import Adapter from 'enzyme-adapter-react-16'
import UserTypeSelector from 'components/signup/user_type_selector'
import { pack } from "../../helpers/pack"

Enzyme.configure({adapter: new Adapter()})

describe('When I try to render signup user type selector', () => {

  it("should render", () => {
    const userTypeSelector = Enzyme.mount(<UserTypeSelector />);
    expect(userTypeSelector.html()).toBe(pack(`
      <div class="user-type-select">
        <button name="type" value="teacher">I am a <strong>Teacher</strong></button>
        <button name="type" value="student">I am a <strong>Student</strong></button>
      </div>
    `));
  });

})