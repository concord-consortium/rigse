import React from 'react'

import css from './student-roster.scss'

export default class StudentRosterRow extends React.Component {
  constructor (props) {
    super(props)
    this.handleRemoveStudent = this.handleRemoveStudent.bind(this)
    this.handleChangePassword = this.handleChangePassword.bind(this)
  }

  handleRemoveStudent () {
    this.props.onRemoveStudent(this.props.student)
  }

  handleChangePassword () {
    this.props.onChangePassword(this.props.student)
  }

  render () {
    const { student, canEdit } = this.props
    const { name, username, last_login: lastLogin, assignments_started: assignmentsStarted } = student

    return (
      <tr>
        <td>{name}</td>
        <td>{username}</td>
        <td>{lastLogin}</td>
        <td>{assignmentsStarted}</td>
        {canEdit ? <td className='hide_in_print'>
          { student.can_remove ? <span className={css.link} role='link' onClick={this.handleRemoveStudent}>Remove Student</span> : undefined }
          { student.can_reset_password ? <span className={css.link} role='link' onClick={this.handleChangePassword}>Change Password</span> : undefined }
        </td> : undefined}
      </tr>
    )
  }
}
