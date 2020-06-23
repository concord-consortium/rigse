/* globals describe it expect */
import React from 'react'

import Enzyme from 'enzyme'
import Adapter from 'enzyme-adapter-react-16'
import TeacherRegistrationComplete from 'components/signup/teacher_registration_complete'
import { pack } from "../../helpers/pack"

Enzyme.configure({adapter: new Adapter()})

window.ga = jest.fn()

describe('When I try to render signup teacher registration complete', () => {

  it("should render with default props", () => {
    const complete = Enzyme.mount(<TeacherRegistrationComplete />);
    expect(complete.html()).toBe(pack(`
      <div class="registration-complete">
        <p class="reg-header">
          Thanks for signing up!
        </p>
        <p>
          <a href="/">Start using the site.</a>
        </p>
      </div>
    `));
  });

  it("should render with anonymous prop", () => {
    const complete = Enzyme.mount(<TeacherRegistrationComplete anonymous={true} />);
    expect(complete.html()).toBe(pack(`
      <div class="registration-complete">
        <p class="reg-header">
          Thanks for signing up!
        </p>
        <p>
          We're sending you an email with your activation code. Click the "Confirm Account" link in the email to complete the process.
        </p>
      </div>
    `));
  });


})