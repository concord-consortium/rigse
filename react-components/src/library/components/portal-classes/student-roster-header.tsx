import React from 'react'

import css from './student-roster.scss'

export default class StudentRosterHeader extends React.Component<any, any> {
  constructor (props: any) {
    super(props)
    this.state = {
      selectedStudent: undefined
    }
    this.handleAddClicked = this.handleAddClicked.bind(this)
    this.handleSelectChanged = this.handleSelectChanged.bind(this)
  }

  handleAddClicked () {
    const { selectedStudent } = this.state
    if (selectedStudent) {
      this.props.onAddStudent(selectedStudent)
    }
  }

  handleSelectChanged (e: any) {
    const id = parseInt(e.target.value, 10)
    const selectedStudent = this.props.otherStudents.find((s: any) => s.id === id)
    this.setState({ selectedStudent })
  }

  renderSelect (otherStudents: any) {
    const { selectedStudent } = this.state
    const { allowDefaultClass } = this.props
    const addDisabled = !selectedStudent

    if (!allowDefaultClass) {
      return <>
        <div className={css.select}>
          <select id='student_id_selector' onChange={this.handleSelectChanged} value={selectedStudent ? selectedStudent.id : '0'}>
            <option value='0'>Select registered student ...</option>
            {otherStudents.map((s: any) => <option key={s.id} value={s.id}>{s.name} ({s.username})</option>)}
          </select>
        </div>
        <div>
          <button disabled={addDisabled} onClick={this.handleAddClicked}>Add</button>
        </div>
      </>;
    }

    return 'If a student already has an account, ask the student to enter the Class Word above'
  }

  render () {
    const otherStudents = this.props.otherStudents || []
    const haveOtherStudents = otherStudents.length > 0

    return (
      <div className={css.header}>
        <div className={css.search}>
          {haveOtherStudents
            ? this.renderSelect(otherStudents)
            : 'Please register students or have them self-register with the class word in order to add them to this class'
          }
        </div>
        <div className={css.or}>
          or
        </div>
        <div>
          <span className={css.link} role='link' onClick={this.props.onRegisterStudent}>Register & Add New Student</span>
        </div>
      </div>
    )
  }
}
