/* globals describe it expect */

import React from 'react'
import Enzyme from 'enzyme'
import Adapter from 'enzyme-adapter-react-16'
import BasicDataForm from 'components/signup/basic_data_form'
import { pack } from "../../helpers/pack"

Enzyme.configure({adapter: new Adapter()})

describe('When I try to render signup basic data form', () => {

  it("should render with default props", () => {
    const basicDataForm = Enzyme.mount(<BasicDataForm />);
    expect(basicDataForm.html()).toBe(pack(`
      <form>
        <div class="third-party-login-options testy"></div>
        <div class="submit-button-container">
          <button class="submit-btn" type="submit"></button>
        </div>
      </form>
    `));
  });

  it("should render with anonymous prop", () => {
    const basicDataForm = Enzyme.mount(<BasicDataForm anonymous={true} />);
    expect(basicDataForm.html()).toBe(pack(`
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
          <button class="submit-btn" type="submit" disabled=""></button>
        </div>
      </form>
    `));
  });

})
