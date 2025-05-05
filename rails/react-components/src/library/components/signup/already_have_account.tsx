import React from "react";

export default class AlreadyHaveAccount extends React.Component<any, any> {
  constructor (props: any) {
    super(props);
    this.handleLoginClick = this.handleLoginClick.bind(this);
  }

  handleLoginClick (event: any) {
    event.preventDefault();
    gtag("event", "click", {
      "category": "User Registration",
      "label": "Already Have Account Log in Link Clicked"
    });

    if (this.props.loginUrl) {
      window.location.href = this.props.loginUrl;
      return;
    }

    PortalComponents.renderLoginModal({
      oauthProviders: this.props.oauthProviders,
      afterSigninPath: this.props.afterSigninPath
    });
    gtag("event", "click", {
      "category": "Login",
      "label": "Login form opened"
    });
  }

  render () {
    return (
      <div className={"signup-form-login-option"}>Already have an account? <a href="/users/sign_in" onClick={this.handleLoginClick}>Log in &raquo;</a></div>
    );
  }
}
