import React from "react";
import TextInput from "./text_input";
import Formsy from "formsy-react";

const enableAuthProviders = true;

export default class LoginModal extends React.Component<any, any> {
  static defaultProps = {
    siteName: (window.Portal?.siteName) || "Portal"
  };

  constructor (props: any) {
    super(props);

    this.submit = this.submit.bind(this);
    this.handleForgotPassword = this.handleForgotPassword.bind(this);
    this.handleRegister = this.handleRegister.bind(this);
  }

  submit (data: any) {
    if (this.props.afterSigninPath) {
      data.after_sign_in_path = this.props.afterSigninPath;
    }

    jQuery.post("/api/v1/users/sign_in", data).done(function (response) {
      // console.log("INFO login success", response);
      if (response.redirect_path) {
        window.location = response.redirect_path;
      } else {
        // @ts-expect-error TS(2554): Expected 0 arguments, but got 1.
        window.location.reload(true);
      }
    }).fail(function (err) {
      // console.log("INFO login error", err);
      // console.log("INFO login error responseText", err.responseText);
      if (err?.responseText) {
        const response = jQuery.parseJSON(err.responseText);
        let message = response.message;
        if (response.error) {
          message = response.error;
        }

        //
        // TODO use some kind of styled modal dialog here.....
        //
        window.alert("Error: " + message);
      }
    });
  }

  handleForgotPassword (e: any) {
    e.preventDefault();
    PortalComponents.renderForgotPasswordModal({ oauthProviders: this.props.oauthProviders });
  }

  handleRegister (e: any) {
    e.preventDefault();
    PortalComponents.renderSignupModal({ oauthProviders: this.props.oauthProviders });
  }

  render () {
    const providerComponents = [];

    if (enableAuthProviders && this.props.oauthProviders) {
      const providers = this.props.oauthProviders;
      providers.sort(function (a: any, b: any) { return (a.name > b.name) ? 1 : ((b.name > a.name) ? -1 : 0); }); // sort providers alphabetically by name
      for (let i = 0; i < providers.length; i++) {
        let directPath = providers[i].directPath;
        if (this.props.afterSigninPath) {
          directPath += "?after_sign_in_path=" + encodeURIComponent(this.props.afterSigninPath);
        }
        providerComponents.push(
          <a className={"badge"} id={providers[i].name} href={directPath}>
            Sign in with { providers[i].display_name }
          </a>
        );
      }
    }

    return (
      <div className={"login-default-modal-content"}>
        <Formsy className={"signup-form"} onValidSubmit={this.submit}>
          <h2>
            <strong>
              Log in
            </strong>
            { " " }
            to the { this.props.siteName }
          </h2>
          <div className={"third-party-login-options"}>
            <p>
              Sign in with:
            </p>
            { providerComponents }
          </div>
          <div className={"or-separator"}>
            <span className={"or-separator-text"}>
              Or
            </span>
          </div>
          <dl>
            <dt>
              Username
            </dt>
            <dd>
              <TextInput name={"user[login]"} placeholder={""} required />
            </dd>
            <dt>
              Password
            </dt>
            <dd>
              <TextInput name={"user[password]"} placeholder={""} type={"password"} required />
            </dd>
          </dl>
          <div className={"submit-button-container"}>
            <a href={"/forgot_password"} onClick={this.handleForgotPassword} title={"Click this link if you forgot your username and/or password."}>
              Forgot your username or password?
            </a>
            <button className={"submit-btn"} type={"submit"}>
              Log In!
            </button>
          </div>
          <footer>
            <p>
              Don't have an account?
              { " " }
              <a href={"#"} onClick={this.handleRegister}>
                Sign up for free
              </a>
              { " " }
              to create classes, assign activities, save student work, track student progress, and more!
            </p>
          </footer>
        </Formsy>
      </div>
    );
  }
}
