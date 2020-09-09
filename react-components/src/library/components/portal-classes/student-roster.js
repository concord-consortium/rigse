import React from 'react'

import RegisterStudentModal from './register-student-modal'
import StudentRosterRow from './student-roster-row'
import StudentRosterHeader from './student-roster-header'

import api from '../../helpers/api'

import css from './student-roster.scss'

const apiBasePath = '/api/v1/students'
const apiCall = api({
  remove: { url: `${apiBasePath}/remove_from_class` },
  add: { url: `${apiBasePath}/add_to_class` },
  register: { url: `${apiBasePath}/register` }
})

export default class StudentRoster extends React.Component {
  constructor (props) {
    super(props)

    this.state = {
      showRegisterStudentModal: false
    }

    this.handleRemoveStudent = this.handleRemoveStudent.bind(this)
    this.handleChangePassword = this.handleChangePassword.bind(this)
    this.handleAddStudent = this.handleAddStudent.bind(this)
    this.handleToggleRegisterStudentModal = this.handleToggleRegisterStudentModal.bind(this)
    this.handleRegisterStudent = this.handleRegisterStudent.bind(this)
  }

  handleRemoveStudent (student) {
    const { clazz } = this.props
    if (window.confirm(`This will remove the student: '${student.name}' from the class: ${clazz.name}.\n\nAre you sure you want to do this?`)) {
      apiCall('remove', {
        data: {
          student_clazz_id: student.student_clazz_id
        },
        errorMessage: 'Unable to remove student!',
        onSuccess: () => window.location.reload()
      })
    }
  }

  handleChangePassword (student) {
    if (student.is_oauth_user) {
      window.alert(`This student is authenticated as a ${student.oauth_provider} user. You cannot change this password.`)
    } else {
      window.location.assign(`/users/${student.user_id}/reset_password`)
    }
  }

  handleAddStudent (otherStudent) {
    apiCall('add', {
      data: {
        clazz_id: this.props.clazz.id,
        student_id: otherStudent.id
      },
      errorMessage: 'Unable to add student!',
      onSuccess: () => window.location.reload()
    })
  }

  handleRegisterStudent (fields) {
    const { firstName, lastName, password, passwordConfirmation } = fields
    apiCall('register', {
      data: {
        clazz_id: this.props.clazz.id,
        user: {
          first_name: firstName,
          last_name: lastName,
          password,
          password_confirmation: passwordConfirmation
        }
      },
      errorMessage: 'Unable to register student!',
      onSuccess: () => window.location.reload()
    })
  }

  handleToggleRegisterStudentModal () {
    this.setState({ showRegisterStudentModal: !this.state.showRegisterStudentModal })
  }

  renderStudents (canEdit) {
    const { students } = this.props

    if (students.length === 0) {
      return <div>No students registered for this class yet.</div>
    }

    return (
      <table className={css.table}>
        <tbody>
          <tr>
            <th>Name</th>
            <th>Username</th>
            <th>Last Login</th>
            <th>Assignments Started</th>
            {canEdit ? <th className='hide_in_print' /> : undefined}
          </tr>
          {students.map(student => (
            <StudentRosterRow
              key={student.student_id}
              student={student}
              canEdit={canEdit}
              onRemoveStudent={this.handleRemoveStudent}
              onChangePassword={this.handleChangePassword}
            />
          ))}
        </tbody>
      </table>
    )
  }

  render () {
    const { showRegisterStudentModal } = this.state
    const { otherStudents, allowDefaultClass, canEdit } = this.props

    return (
      <>
        {canEdit ? <StudentRosterHeader allowDefaultClass={allowDefaultClass} otherStudents={otherStudents} onAddStudent={this.handleAddStudent} onRegisterStudent={this.handleToggleRegisterStudentModal} /> : undefined}
        {this.renderStudents(canEdit)}
        {showRegisterStudentModal ? <RegisterStudentModal onSubmit={this.handleRegisterStudent} onCancel={this.handleToggleRegisterStudentModal} /> : undefined }
      </>
    )
  }
}
