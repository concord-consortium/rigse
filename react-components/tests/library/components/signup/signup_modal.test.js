/* globals describe it expect */
import React from 'react'
import Enzyme from 'enzyme'
import Adapter from 'enzyme-adapter-react-16'
import SignupModal from 'components/signup/signup_modal'
import { pack } from "../../helpers/pack"

Enzyme.configure({adapter: new Adapter()})

describe('When I try to render signup modal', () => {

  it("should render", () => {
    const signupModal = Enzyme.mount(<SignupModal />);
    expect(signupModal.html()).toBe(pack(`
      <div class="signup-default-modal-content">
        <div>
          <h2><strong>Finish</strong> Signing Up</h2>
          <div class="signup-form">
            <div class="user-type-select">
              <button name="type" value="teacher">I am a <strong>Teacher</strong></button>
              <button name="type" value="student">I am a <strong>Student</strong></button>
            </div>
          </div>
          <footer class="reg-footer">
            <p>
              <strong>Why sign up?</strong> It's free and you get access to several key features, like creating classes for your students, assigning activities, saving work, tracking student progress, and more!
            </p>
          </footer>
        </div>
      </div>
    `));
  });

})
