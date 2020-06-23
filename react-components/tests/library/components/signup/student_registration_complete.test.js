/* globals describe it expect */
import React from 'react'
import Enzyme from 'enzyme'
import Adapter from 'enzyme-adapter-react-16'
import StudentRegistrationComplete from 'components/signup/student_registration_complete'
import { pack } from "../../helpers/pack"

Enzyme.configure({adapter: new Adapter()})

global.ga = jest.fn()

describe('When I try to render signup student registration complete', () => {

  it("should render as anonymous", () => {
    const complete = Enzyme.mount(<StudentRegistrationComplete anonymous={true} data={{login: "data-login"}} />);
    expect(complete.html()).toBe(pack(`
      <div class="registration-complete student">
        <div>
          <p style="margin-bottom: 30px;">Success! Your username is <span class="login">data-login</span></p>
          <p style="margin-bottom: 30px;">Use your new account to sign in below.</p>
        </div>
        <form class="signup-form">
          <dl>
            <dt>Username</dt>
            <dd>
              <div class="text-input user[login]">
                <input type="text" placeholder="" value="">
                <div class="input-error"></div>
              </div>
            </dd>
            <dt>Password</dt>
            <dd>
              <div class="text-input user[password]">
                <input type="password" placeholder="" value="">
                <div class="input-error"></div>
              </div>
            </dd>
          </dl>
          <div class="submit-button-container">
            <button class="submit-btn" type="submit">Log In!</button>
          </div>
        </form>
      </div>
    `));
  });

})