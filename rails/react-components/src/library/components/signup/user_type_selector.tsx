import React from "react";

export default class UserTypeSelector extends React.Component<any, any> {
  constructor (props: any) {
    super(props);
    this.handleClick = this.handleClick.bind(this);
  }

  handleClick (event: any) {
    const value = event.currentTarget.value;
    gtag("event", "click", {
      "category": "User Registration",
      "label": "Step 1 Completed - " + value.charAt(0).toUpperCase() + value.slice(1)
    });

    this.props.onUserTypeSelect(value);
  }

  render () {
    return (
      <div className="user-type-select">
        <button onClick={this.handleClick} name="type" value="teacher">
          I am a <strong>Teacher</strong>
        </button>
        <button onClick={this.handleClick} name="type" value="student">
          I am a <strong>Student</strong>
        </button>
      </div>
    );
  }
}
