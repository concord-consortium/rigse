/* globals describe it expect */
import React from 'react'
import Enzyme from 'enzyme'
import Adapter from 'enzyme-adapter-react-16'
import TeacherForm from 'components/signup/teacher_form'
import { pack } from "../../helpers/pack"

Enzyme.configure({adapter: new Adapter()})

global.Portal = {
  enewsSubscriptionEnabled: true,
  API_V1: {
    LOGIN_VALID: "http://example.com/login_valid",
    EMAILS: "http://example.com/emails",
    COUNTRIES: "http://example.com/countries",
    TEACHERS: "http://example.com/teachers",
  }
}

describe('When I try to render signup user type selector', () => {

  it("should render", () => {
    const teacherForm = Enzyme.mount(<TeacherForm />);
    expect(teacherForm.html()).toBe(pack(`
      <form>
        <dl>
          <dt>Country</dt>
          <dd>
            <div class="select-input">
              <div class=" css-2b097c-container">
                <div class=" css-yk16xz-control">
                  <div class=" css-g1d714-ValueContainer">
                    <div class=" css-1wa3eu0-placeholder"></div>
                    <div class="css-b8ldur-Input">
                      <div class="" style="display: inline-block;">
                        <input autocapitalize="none" autocomplete="off" autocorrect="off" id="react-select-2-input" spellcheck="false" tabindex="0" type="text" aria-autocomplete="list" style="box-sizing: content-box; width: 2px; border: 0px; font-size: inherit; opacity: 1; outline: 0; padding: 0px;" value="">
                        <div style="position: absolute; top: 0px; left: 0px; visibility: hidden; height: 0px; overflow: scroll; white-space: pre; font-size: inherit; font-family: -webkit-small-control; letter-spacing: normal; text-transform: none;"></div>
                      </div>
                    </div>
                  </div>
                  <div class=" css-1hb7zxy-IndicatorsContainer">
                    <span class=" css-1okebmr-indicatorSeparator"></span>
                    <div aria-hidden="true" class=" css-tlfecz-indicatorContainer">
                      <svg height="20" width="20" viewBox="0 0 20 20" aria-hidden="true" focusable="false" class="css-6q0nyr-Svg">
                        <path d="M4.516 7.548c0.436-0.446 1.043-0.481 1.576 0l3.908 3.747 3.908-3.747c0.533-0.481 1.141-0.446 1.574 0 0.436 0.445 0.408 1.197 0 1.615-0.406 0.418-4.695 4.502-4.695 4.502-0.217 0.223-0.502 0.335-0.787 0.335s-0.57-0.112-0.789-0.335c0 0-4.287-4.084-4.695-4.502s-0.436-1.17 0-1.615z"></path>
                      </svg>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </dd>
        </dl>
        <dl>
          <dd></dd>
        </dl>
        <div class="signup-form-enews-optin-standalone">
          <div class="checkbox-input email_subscribed">
            <label class="checkbox-label">
              <input type="checkbox" checked="">
              Send me updates about educational technology resources.
            </label>
          </div>
        </div>
        <div class="privacy-policy">
          By clicking Register!, you agree to our <a href="https://concord.org/privacy-policy" target="_blank">privacy policy.</a>
        </div>
        <div class="submit-button-container">
          <button class="submit-btn" type="submit" disabled="">Register!</button>
        </div>
      </form>
    `));
  });

  it("should render with anonymous prop", () => {
    const teacherForm = Enzyme.mount(<TeacherForm anonymous={true} />);
    expect(teacherForm.html()).toBe(pack(`
      <form>
        <div>
          <dl>
            <dt>Username</dt>
            <dd>
              <div class="text-input login valid">
                <input type="text" placeholder="" value="">
                <div class="input-error"></div>
              </div>
            </dd>
            <dt>Email</dt>
            <dd>
              <div class="text-input email valid">
                <input type="text" placeholder="" value="">
                <div class="input-error"></div>
              </div>
            </dd>
            <dd>
              <div class="checkbox-input email_subscribed">
                <label class="checkbox-label">
                  <input type="checkbox" checked="">Send me updates about educational technology resources.
                </label>
              </div>
            </dd>
          </dl>
        </div>
        <dl>
          <dt>Country</dt>
          <dd>
            <div class="select-input">
              <div class=" css-2b097c-container">
                <div class=" css-yk16xz-control">
                  <div class=" css-g1d714-ValueContainer">
                    <div class=" css-1wa3eu0-placeholder"></div>
                    <div class="css-b8ldur-Input">
                      <div class="" style="display: inline-block;">
                        <input autocapitalize="none" autocomplete="off" autocorrect="off" id="react-select-3-input" spellcheck="false" tabindex="0" type="text" aria-autocomplete="list" style="box-sizing: content-box; width: 2px; border: 0px; font-size: inherit; opacity: 1; outline: 0; padding: 0px;" value="">
                        <div style="position: absolute; top: 0px; left: 0px; visibility: hidden; height: 0px; overflow: scroll; white-space: pre; font-size: inherit; font-family: -webkit-small-control; letter-spacing: normal; text-transform: none;"></div>
                      </div>
                    </div>
                  </div>
                  <div class=" css-1hb7zxy-IndicatorsContainer">
                    <span class=" css-1okebmr-indicatorSeparator"></span>
                    <div aria-hidden="true" class=" css-tlfecz-indicatorContainer">
                      <svg height="20" width="20" viewBox="0 0 20 20" aria-hidden="true" focusable="false" class="css-6q0nyr-Svg">
                        <path d="M4.516 7.548c0.436-0.446 1.043-0.481 1.576 0l3.908 3.747 3.908-3.747c0.533-0.481 1.141-0.446 1.574 0 0.436 0.445 0.408 1.197 0 1.615-0.406 0.418-4.695 4.502-4.695 4.502-0.217 0.223-0.502 0.335-0.787 0.335s-0.57-0.112-0.789-0.335c0 0-4.287-4.084-4.695-4.502s-0.436-1.17 0-1.615z"></path>
                      </svg>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </dd>
        </dl>
        <dl>
          <dd></dd>
        </dl>
        <div class="privacy-policy">
          By clicking Register!, you agree to our <a href="https://concord.org/privacy-policy" target="_blank">privacy policy.</a>
        </div>
        <div class="submit-button-container">
          <button class="submit-btn" type="submit" disabled="">Register!</button>
        </div>
      </form>
    `))
  });

})