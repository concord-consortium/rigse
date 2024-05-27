import React from 'react'

import RegisterStudentModal from './register-student-modal'
import StudentRosterRow from './student-roster-row'
import ModalDialog from '../shared/modal-dialog'

import api from '../../helpers/api'

import css from './student-roster.scss'
import modalDialogCSS from '../shared/modal-dialog.scss'

const apiBasePath = '/api/v1/students'
const apiCall = api({
  remove: { url: `${apiBasePath}/remove_from_class` },
  add: { url: `${apiBasePath}/add_to_class` },
  register: { url: `${apiBasePath}/register` }
})

const REGISTERED_STUDENT_HASH_MARKER = '#registered_student'

export default class StudentRoster extends React.Component<any, any> {
  constructor (props: any) {
    super(props)

    this.state = {
      showRegisterStudentModal: false,
      showRegisterAnotherStudentModal: false
    }

    this.handleRemoveStudent = this.handleRemoveStudent.bind(this)
    this.handleChangePassword = this.handleChangePassword.bind(this)
    this.handleAddStudent = this.handleAddStudent.bind(this)
    this.handleToggleRegisterStudentModal = this.handleToggleRegisterStudentModal.bind(this)
    this.handleRegisterStudent = this.handleRegisterStudent.bind(this)
    this.handleToggleRegisterAnotherModal = this.handleToggleRegisterAnotherModal.bind(this)
    this.handleRegisterAnotherStudent = this.handleRegisterAnotherStudent.bind(this)
  }

  // eslint-disable-next-line camelcase
  UNSAFE_componentWillMount () {
    if (window.location.hash === REGISTERED_STUDENT_HASH_MARKER) {
      this.setState({ showRegisterAnotherStudentModal: true })
      window.location.hash = ''
    }
  }

  handleRemoveStudent (student: any) {
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

  handleChangePassword (student: any) {
    if (student.is_oauth_user) {
      window.alert(`This student is authenticated as a ${student.oauth_provider} user. You cannot change this password.`)
    } else {
      window.location.assign(`/users/${student.user_id}/reset_password`)
    }
  }

  handleAddStudent (otherStudent: any) {
    apiCall('add', {
      data: {
        clazz_id: this.props.clazz.id,
        student_id: otherStudent.id
      },
      errorMessage: 'Unable to add student!',
      onSuccess: () => window.location.reload()
    })
  }

  handleRegisterStudent (fields: any) {
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
      onSuccess: () => {
        // trigger the "register another student?" modal after reload
        window.location.hash = REGISTERED_STUDENT_HASH_MARKER
        window.location.reload()
      }
    })
  }

  handleToggleRegisterStudentModal () {
    this.setState({ showRegisterStudentModal: !this.state.showRegisterStudentModal })
  }

  handleToggleRegisterAnotherModal () {
    this.setState({ showRegisterAnotherStudentModal: !this.state.showRegisterAnotherStudentModal })
  }

  handleRegisterAnotherStudent () {
    this.setState({
      showRegisterStudentModal: true,
      showRegisterAnotherStudentModal: false
    })
  }

  renderRegisterAnotherModal () {
    return (
      <ModalDialog title='Success! The student was registered and added to the class'>
        <p>
          Do you wish to register and add another student?
        </p>
        <p className={modalDialogCSS.buttons}>
          <button onClick={this.handleRegisterAnotherStudent}>Add Another Student</button>
          <button onClick={this.handleToggleRegisterAnotherModal}>Cancel</button>
        </p>
      </ModalDialog>
    )
  }

  renderStudents (canEdit: any) {
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
          {students.map((student: any) => <StudentRosterRow
            key={student.student_id}
            student={student}
            canEdit={canEdit}
            onRemoveStudent={this.handleRemoveStudent}
            onChangePassword={this.handleChangePassword}
          />)}
        </tbody>
      </table>
    );
  }

  render () {
    const { showRegisterStudentModal, showRegisterAnotherStudentModal } = this.state
    const { canEdit } = this.props

    return (
      <>
        {/* {canEdit ? <StudentRosterHeader allowDefaultClass={allowDefaultClass} otherStudents={otherStudents} onAddStudent={this.handleAddStudent} onRegisterStudent={this.handleToggleRegisterStudentModal} /> : undefined} */}
        {this.renderStudents(canEdit)}
        {showRegisterStudentModal ? <RegisterStudentModal onSubmit={this.handleRegisterStudent} onCancel={this.handleToggleRegisterStudentModal} /> : undefined }
        {showRegisterAnotherStudentModal ? this.renderRegisterAnotherModal() : undefined}
      </>
    )
  }
}
