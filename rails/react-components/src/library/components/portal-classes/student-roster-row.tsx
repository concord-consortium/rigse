import React from "react";
import TriStateCheckbox from "../common/tri-state-checkbox";

import css from "./student-roster.scss";

export default class StudentRosterRow extends React.Component<any, any> {
  constructor (props: any) {
    super(props);
    this.handleRemoveStudent = this.handleRemoveStudent.bind(this);
    this.handleChangePassword = this.handleChangePassword.bind(this);
    this.handleStudentCheckboxChange = this.handleStudentCheckboxChange.bind(this);
  }

  handleRemoveStudent () {
    this.props.onRemoveStudent(this.props.student);
  }

  handleChangePassword () {
    this.props.onChangePassword(this.props.student);
  }

  handleStudentCheckboxChange (checked: boolean) {
    this.props.onStudentCheckboxChange(this.props.student, checked);
  }

  render () {
    const { student, canEdit, canManageStudents, studentCheckboxChecked } = this.props;
    const { name, username, last_login: lastLogin, assignments_started: assignmentsStarted } = student;

    return (
      <tr>
        { canManageStudents &&
          <td><TriStateCheckbox checked={studentCheckboxChecked} onChange={this.handleStudentCheckboxChange} /></td>
        }
        <td>{ name }</td>
        <td>{ username }</td>
        <td>{ lastLogin }</td>
        <td>{ assignmentsStarted }</td>
        {
          canEdit ?
            <td className="hide_in_print">
              { student.can_remove ? <span className={css.link} role="link" onClick={this.handleRemoveStudent}>Remove Student</span> : undefined }
              { student.can_reset_password ? <span className={css.link} role="link" onClick={this.handleChangePassword}>Change Password</span> : undefined }
            </td> : undefined
        }
      </tr>
    );
  }
}
