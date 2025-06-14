import React from "react";
import TextInput from "./text_input";
import Formsy from "formsy-react";

export default class ForgotPasswordModal extends React.Component<any, any> {
  static defaultProps = {
    siteName: (window.Portal?.siteName) || "Portal"
  };

  constructor (props: any) {
    super(props);

    this.submit = this.submit.bind(this);
    this.handleShowSignup = this.handleShowSignup.bind(this);
  }

  submit (loginData: any) {
    const login = loginData.user.login;
    const data = { login_or_email: login };
    jQuery.post("/api/v1/passwords/reset_password", data).done(function (response) {
      jQuery(".forgot-password-form p, .forgot-password-form dl, .forgot-password-form div").fadeOut(300);
      jQuery(".forgot-password-form footer").fadeOut(300, function () {
        jQuery(".forgot-password-form").append("<p>" + response.message + "</p>");
      });
    }).fail(function (err) {
      if (err?.responseText) {
        const response = jQuery.parseJSON(err.responseText);
        let message = response.message;
        if (response.error) {
          message = response.error;
        }

        //
        // TODO use some kind of styled modal dialog here.....
        //
        jQuery(".input-error").text("Error: " + message);
        jQuery(".input-error").css("color", "#ea6d2f").fadeOut(200).fadeIn(200).fadeOut(200).fadeIn(200);
      }
    });
  }

  handleShowSignup (e: any) {
    e.preventDefault();
    PortalComponents.renderSignupModal({ oauthProviders: this.props.oauthProviders });
  }

  render () {
    return (
      <div className="forgot-password-default-modal-content">
        <Formsy className="forgot-password-form" onValidSubmit={this.submit} role="form" aria-roledescription="form">

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
              <TextInput name="user[login]" placeholder="" required autoFocus={true} />
            </dd>
          </dl>
          <div className="submit-button-container">
            <button className="submit-btn" type="submit">
              Submit
            </button>
          </div>

          <footer>
            <p>
              Don't have an account?
              &nbsp;<a href="#" onClick={this.handleShowSignup}>Create an account</a> for free and get access to bonus features!
              &nbsp;<strong>Students</strong> can save their work and get feedback.
              &nbsp;<strong>Teachers</strong> can create classes, assign activities, track student progress and more!
            </p>
          </footer>
        </Formsy>
      </div>
    );
  }
}
