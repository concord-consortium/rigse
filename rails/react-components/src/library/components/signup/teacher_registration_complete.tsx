import React from "react";

export default class TeacherRegistrationComplete extends React.Component<any, any> {
  componentDidMount () {
    gtag("event", "click", {
      "category": "User Registration",
      "label": "Final Step Completed - Teacher"
    });
  }

  render () {
    const successMessage = this.props.anonymous
      ? <p>We're sending you an email with your activation code. Click the "Confirm Account" link in the email to complete the process.</p>
      : <p><a href="/">Start using the site.</a></p>;

    return (
      <div className="registration-complete">
        <p className="reg-header">Thanks for signing up!</p>
        { successMessage }
      </div>
    );
  }
}
