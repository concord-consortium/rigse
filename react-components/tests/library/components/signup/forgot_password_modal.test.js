/* globals describe it expect */
import React from 'react'
import Enzyme from 'enzyme'
import Adapter from 'enzyme-adapter-react-16'
import ForgotPasswordModal from 'components/signup/forgot_password_modal'
import { pack } from "../../helpers/pack"

Enzyme.configure({adapter: new Adapter()})

describe('When I try to render signup user type selector', () => {

  it("should render", () => {
    const forgotPasswordModal = Enzyme.mount(<ForgotPasswordModal />);
    expect(forgotPasswordModal.html()).toBe(pack(`
      <div class="forgot-password-default-modal-content">
        <form class="forgot-password-form">
          <h2><strong>Forgot</strong> your login information?</h2>
          <p>
            <strong>Students:</strong> Ask your teacher for help.
          </p>
          <p>
            <strong>Teachers:</strong> Enter your username or email address below.
          </p>
          <dl>
            <dt>Username or Email Address</dt>
            <dd>
              <div class="text-input user[login]">
                <input type="text" placeholder="" value="">
                <div class="input-error"></div>
              </div>
            </dd>
          </dl>
          <div class="submit-button-container">
            <button class="submit-btn" type="submit">Submit</button>
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