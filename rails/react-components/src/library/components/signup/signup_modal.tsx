import React from "react";
import Signup from "./signup";

export default class SignupModal extends React.Component<any, any> {
  render () {
    return (
      <div className="signup-default-modal-content">
        <Signup {...this.props} />
      </div>
    );
  }
}
