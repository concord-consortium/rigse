import React from 'react'

import css from './style.scss'

const formatDate = date => `${date.getMonth() + 1}/${date.getDate()}/${date.getFullYear()}`

export default class ProgressTable extends React.Component {
  getFeedbackOptions (activityId) {
    const { activities } = this.props
    return activities.find(a => a.id === activityId).feedbackOptions
  }

  renderActivityHeader (act) {
    const name = <span className={css.activityTitle}>{ act.name }</span>
    return act.reportUrl
      ? <a href={act.reportUrl} target='_blank' title={`Open report for "${act.name}"`}>{ name }</a>
      : name
  }

  renderStudentName (student) {
    const name = <span className={css.name}>{ student.name }</span>
    return student.reportUrl && student.totalProgress > 0
      ? <a href={student.reportUrl} target='_blank' title={`Open report for ${student.name}`}>{ name }</a>
      : name
  }

  render () {
    const { students } = this.props
    if (students.length === 0) {
      return null
    }
    return (
      <div className={css.offeringProgress}>
        <div className={css.namesTableContainer}>
          <table className={css.namesTable}>
            <tbody>
              <tr>
                <th>Student</th>
                <th className={css.dateHeader}>Last Run</th>
                <th>Status</th>
              </tr>
              {
                students.map(student =>
                  <tr key={student.id}>
                    <td>{ this.renderStudentName(student) }</td>
                    <td className={css.date} title={student.lastRun && student.lastRun.toLocaleDateString()}>
                      { student.lastRun ? formatDate(student.lastRun) : 'n/a' }
                    </td>
                    <td className={css.status}>
                      { student.startedActivity ? 'Started' : 'Not Started' }
                    </td>
                  </tr>
                )
              }
            </tbody>
          </table>
        </div>
      </div>
    )
  }
}
