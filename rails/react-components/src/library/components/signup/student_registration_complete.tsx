import React from "react";
import Formsy from "formsy-react";
import TextInput from "./text_input";

export default class StudentRegistrationComplete extends React.Component<any, any> {
  constructor (props: any) {
    super(props);
    this.submit = this.submit.bind(this);
  }

  componentDidMount () {
    gtag("event", "click", {
      "category": "User Registration",
      "label": "Form",
      "action": "Final Step Completed - Student"
    });
  }

  submit (data: any) {
    if (this.props.afterSigninPath) {
      data.after_sign_in_path = this.props.afterSigninPath;
    }

    jQuery.post("/api/v1/users/sign_in", data).done(function (response) {
      if (response.redirect_path) {
        window.location = response.redirect_path;
      } else {
        window.location.reload();
      }
    }).fail(function (err) {
      console.error("INFO login error", err);
      console.error("INFO login error responseText", err.responseText);
      const response = jQuery.parseJSON(err.responseText);
      //
      // TODO use some kind of styled modal dialog here.....
      //
      window.alert("Error: " + response.message);
    });
  }

  render () {
    const { anonymous, data, loginUrl } = this.props;
    const { login } = data;

    const loginMessage = loginUrl ? "Click the login button below to sign in." : "Use your new account to sign in below.";

    const successMessage = anonymous
      ? <div><p style={{ marginBottom: "30px" }}>Success! Your username is <span className="login">{ login }</span></p><p style={{ marginBottom: "30px" }}>{loginMessage}</p></div>
      : <p><a href="/">Start using the site.</a></p>;

    if (loginUrl) {
      return (
        <div className="registration-complete student">
          { successMessage }
          <div className="submit-button-container">
            <a href={loginUrl} className="submit-btn">Log In!</a>
          </div>
        </div>
      );
    }

    return (
      <div className="registration-complete student">
        { successMessage }
        <Formsy className="signup-form" onValidSubmit={this.submit}>
          <dl>
            <dt>Username</dt>
            <dd>
              <TextInput name="user[login]" placeholder="" required />
            </dd>
            <dt>Password</dt>
            <dd>
              <TextInput name="user[password]" placeholder="" type="password" required />
            </dd>
          </dl>
          <div className="submit-button-container">
            <button className="submit-btn" type="submit">Log In!</button>
          </div>
        </Formsy>
      </div>
    );
  }
}
