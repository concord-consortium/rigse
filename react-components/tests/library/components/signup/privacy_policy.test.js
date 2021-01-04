/* globals describe it expect */
import React from 'react'

import Enzyme from 'enzyme'
import Adapter from 'enzyme-adapter-react-16'
import PrivacyPolicy from 'components/signup/privacy_policy'
import { pack } from "../../helpers/pack"

Enzyme.configure({adapter: new Adapter()})

describe('When I try to render signup privacy policy', () => {

  it("should render", () => {
    const privacyPolicy = Enzyme.mount(<PrivacyPolicy />);
    expect(privacyPolicy.html()).toBe(pack(`
      <div class="privacy-policy">
        By clicking Register!, you agree to our <a href="https://concord.org/privacy-policy" target="_blank">privacy policy.</a>
      </div>
    `));
  });

})