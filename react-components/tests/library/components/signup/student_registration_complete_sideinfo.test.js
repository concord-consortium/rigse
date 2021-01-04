/* globals describe it expect */
import React from 'react'

import Enzyme from 'enzyme'
import Adapter from 'enzyme-adapter-react-16'
import StudentRegistrationCompleteSideInfo from 'components/signup/student_registration_complete_sideinfo'
import { pack } from "../../helpers/pack"
import {mockJquery} from "../../helpers/mock-jquery"

Enzyme.configure({adapter: new Adapter()})

const mockedJQuery = () => ({
  each: () => {},
  attr: () => ""
});

describe('When I try to render signup student registration complete sideinfo', () => {

  mockJquery(mockedJQuery)

  it("should render", () => {
    const complete = Enzyme.mount(<StudentRegistrationCompleteSideInfo />);
    expect(complete.html()).toBe(pack(`
      <div>
        <div class="side-info-header">Sign In</div>
        <form method="post" action="/users/sign_in" class="ng-pristine ng-valid">
          <dl>
            <dt>Username</dt>
            <dd>
              <input name="user[login]">
            </dd>
            <dt>Password</dt>
            <dd>
              <input type="password" name="user[password]">
            </dd>
          </dl>
          <input class="button" type="submit" value="Log In">
        </form>
      </div>
    `));
  });

})