import React from "react";
import Modal from "../../helpers/modal";

export default class TeacherRegistrationComplete extends React.Component<any, any> {
  componentDidMount () {
    // don't allow the user to close the modal by clicking on the background overlay
    // so that the user does not miss checking their email in the the success message
    Modal.disableHide(true);

    gtag("event", "click", {
      "category": "User Registration",
      "label": "Final Step Completed - Teacher"
    });
  }

  handleClose () {
    Modal.forceCloseModal();
  }

  render () {
    const successMessage = this.props.anonymous
      ? <p>We're sending you an email with your activation code. Click the "Confirm Account" link in the email to complete the process.</p>
      : <p><a href="/">Start using the site.</a></p>;

    return (
      <>
        <div className="registration-complete">
          <p className="reg-header">Thanks for signing up!</p>
          { successMessage }
        </div>
        <p>
          <button className="button" onClick={() => this.handleClose()}>Close</button>
        </p>
      </>
    );
  }
}
