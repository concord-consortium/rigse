/* globals describe it expect */
import React from 'react'
import Enzyme from 'enzyme'
import Adapter from 'enzyme-adapter-react-16'
import SignUp from 'components/signup/signup'
import { pack } from "../../helpers/pack"

Enzyme.configure({adapter: new Adapter()})

global.ga = jest.fn()

describe('When I try to render signup student form', () => {

  it("should render with default props", () => {
    const signUp = Enzyme.mount(<SignUp />);
    expect(signUp.html()).toBe(pack(`
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
    `));
  });

  it("should render with anonymous prop", () => {
    const signUp = Enzyme.mount(<SignUp anonymous={true} />);
    expect(signUp.html()).toBe(pack(`
      <div>
        <h2><strong>Register</strong> for the Portal</h2>
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
    `));
  });

  it("should render teacher signup", () => {
    const signUp = Enzyme.mount(<SignUp anonymous={true} />);
    const teacherButton = signUp.find("button").at(0)
    teacherButton.simulate("click")
    signUp.update()
    expect(signUp.html()).toBe(pack(`
      <div>
        <h2><strong>Register as a Teacher</strong> for the Portal</h2>
        <div class="signup-form">
          <form>
            <div class="third-party-login-options testy"></div>
          <div>
            <dl>
              <dt class="two-col">First Name</dt>
              <dd class="name_wrapper first-name-wrapper two-col">
                <div class="text-input first_name">
                  <input type="text" placeholder="" value="">
                  <div class="input-error"></div>
                </div>
              </dd>
              <dt class="two-col">Last Name</dt>
              <dd class="name_wrapper last-name-wrapper two-col">
                <div class="text-input last_name">
                  <input type="text" placeholder="" value="">
                  <div class="input-error"></div>
                </div>
              </dd>
              <dt>Password</dt>
              <dd>
                <div class="text-input password">
                  <input type="password" placeholder="" value="">
                  <div class="input-error"></div>
                </div>
              </dd>
              <dt>Confirm Password</dt>
              <dd>
                <div class="text-input password_confirmation">
                  <input type="password" placeholder="" value="">
                  <div class="input-error"></div>
                </div>
              </dd>
            </dl>
          </div>
          <div class="submit-button-container">
            <button class="submit-btn" type="submit" disabled="">Next</button>
          </div>
        </form>
        </div>
        <footer class="reg-footer">
          <p>
            <strong>Why sign up?</strong> It's free and you get access to several key features, like creating classes for your students, assigning activities, saving work, tracking student progress, and more!
          </p>
        </footer>
      </div>
    `));
  });

  it("should render student signup", () => {
    const signUp = Enzyme.mount(<SignUp anonymous={true} />);
    const studentButton = signUp.find("button").at(1)
    studentButton.simulate("click")
    signUp.update()
    expect(signUp.html()).toBe(pack(`
      <div>
        <h2><strong>Register as a Student</strong> for the Portal</h2>
        <div class="signup-form">
          <form>
            <div class="third-party-login-options testy"></div>
            <div>
              <dl>
                <dt class="two-col">First Name</dt>
                <dd class="name_wrapper first-name-wrapper two-col">
                  <div class="text-input first_name">
                    <input type="text" placeholder="" value="">
                    <div class="input-error"></div>
                  </div>
                </dd>
                <dt class="two-col">Last Name</dt>
                <dd class="name_wrapper last-name-wrapper two-col">
                  <div class="text-input last_name">
                    <input type="text" placeholder="" value="">
                    <div class="input-error"></div>
                  </div>
                </dd>
                <dt>Password</dt>
                <dd>
                  <div class="text-input password">
                    <input type="password" placeholder="" value="">
                    <div class="input-error"></div>
                  </div>
                </dd>
                <dt>Confirm Password</dt>
                <dd>
                  <div class="text-input password_confirmation">
                    <input type="password" placeholder="" value="">
                    <div class="input-error"></div>
                  </div>
                </dd>
              </dl>
            </div>
            <div class="submit-button-container">
              <button class="submit-btn" type="submit" disabled="">Next</button>
            </div>
          </form>
        </div>
        <footer class="reg-footer">
          <p>
            <strong>Why sign up?</strong> It's free and you get access to several key features, like creating classes for your students, assigning activities, saving work, tracking student progress, and more!
          </p>
        </footer>
      </div>
    `));
  });
});
