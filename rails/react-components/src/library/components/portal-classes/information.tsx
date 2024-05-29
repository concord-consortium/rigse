import React from "react";

export default class PortalClassInformation extends React.Component<any, any> {
  render () {
    const { portalClass, portalClassTeacher } = this.props;
    return (
      <dl className="classdata">
        <dt>Teacher:</dt>
        <dd> { portalClassTeacher ? portalClassTeacher.name : "" }</dd>
        <dt>Class Word:</dt>
        <dd> { portalClass.class_word.substr(0, 25) }</dd>
      </dl>
    );
  }
}
