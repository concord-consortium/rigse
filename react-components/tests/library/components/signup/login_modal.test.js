/* globals describe it expect */
import React from 'react'
import Enzyme from 'enzyme'
import Adapter from 'enzyme-adapter-react-16'
import LoginModal from 'components/signup/login_modal'
import { pack } from "../../helpers/pack"

Enzyme.configure({adapter: new Adapter()})

describe('When I try to render signup user type selector', () => {

  it("should render", () => {
    const loginModal = Enzyme.mount(<LoginModal />);
    expect(loginModal.html()).toBe(pack(`
      <div class="login-default-modal-content">
        <form class="signup-form">
          <h2><strong>Log in</strong> to the Portal</h2>
          <div class="third-party-login-options">
            <p>Sign in with:</p>
          </div>
          <div class="or-separator">
            <span class="or-separator-text">Or</span>
          </div>
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
            <a href="/forgot_password" title="Click this link if you forgot your username and/or password.">Forgot your username or password?</a>
            <button class="submit-btn" type="submit">Log In!</button>
          </div>
          <footer>
            <p>
              Don't have an account? <a href="#">Sign up for free</a> to create classes, assign activities, save student work, track student progress, and more!
            </p>
          </footer>
        </form>
      </div>
    `));
  });

})