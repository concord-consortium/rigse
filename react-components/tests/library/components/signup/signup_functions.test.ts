/* globals describe it expect */
// @ts-expect-error TS(2307): Cannot find module 'components/signup/signup_funct... Remove this comment to see the full error message
import {renderSignupForm, openLoginModal, openForgotPasswordModal, openSignupModal} from 'components/signup/signup_functions'

describe('When I try to load signup functions', () => {

  it("should export functions", () => {
    expect(renderSignupForm).toBeDefined()
    expect(openLoginModal).toBeDefined()
    expect(openForgotPasswordModal).toBeDefined()
    expect(openSignupModal).toBeDefined()
  });

})
