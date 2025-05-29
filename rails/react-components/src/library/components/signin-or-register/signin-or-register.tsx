import React from "react";

import css from "./signin-or-register.scss";
import clsx from "clsx";

interface Props {
  appName?: string;
  loginUrl?: string;
  classWord?: string;
}

const SigninOrRegister = ({appName, loginUrl, classWord}: Props) => {

  const handleLogin = (e: React.MouseEvent) => {
    // if no loginUrl is provided, show the login modal
    if (!loginUrl) {
      e.preventDefault();
      PortalComponents.renderLoginModal({ oauthProviders: Portal.oauthProviders });
    }
  };

  const handleRegister = (e: React.MouseEvent) => {
    e.preventDefault();
    PortalComponents.renderSignupModal({ oauthProviders: Portal.oauthProviders, loginUrl, classWord });
  };

  return (
    <div className={css.signinOrRegister}>
      {appName && (
        <div className={css.topMessage}>
          You will automatically return to the {appName} app after logging in or creating an account.
        </div>
      )}
      <div className={css.panels}>
        <div className={css.panel}>
          <div className={css.top}>
            Have an account with the Concord Consortium?
          </div>
          <div className={css.bottom}>
            <a href={loginUrl ?? "#"} className={css.button} onClick={handleLogin}>Login</a>
          </div>
        </div>

        <div className={css.panel}>
          <div className={css.top}>
            No account?
          </div>
          <div className={css.bottom}>
            <a href="#" className={clsx(css.button, css.reverse)} onClick={handleRegister}>Create Account</a>
          </div>
        </div>
      </div>
    </div>
  );
};

export default SigninOrRegister;
