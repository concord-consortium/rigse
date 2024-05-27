import { renderSignupForm, openLoginModal, openForgotPasswordModal, openSignupModal } from "../../../../src/library/components/signup/signup_functions";

describe("When I try to load signup functions", () => {

  it("should export functions", () => {
    expect(renderSignupForm).toBeDefined();
    expect(openLoginModal).toBeDefined();
    expect(openForgotPasswordModal).toBeDefined();
    expect(openSignupModal).toBeDefined();
  });

});
