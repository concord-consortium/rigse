import React from 'react'
import ProgressBar from './progress-bar'

import css from './style.scss'

const formatDate = date => `${date.getMonth() + 1}/${date.getDate()}`

const notLaunchedDetailedProgress = activities => activities.map(a => ({ activityId: a.id, progress: 0, reportUrl: null }))
const launchedDetailedProgress = activities => activities.map(a => ({ activityId: a.id, progress: 100, info: 'launched', reportUrl: null }))

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

  renderStudentProgressBars (student) {
    const { activities } = this.props
    let detailedProgress = []
    if (student.detailedProgress) {
      // Detailed progress available. Render it.
      detailedProgress = student.detailedProgress
    } else if (!student.startedActivity) {
      // Otherwise, there are two options. Student has run offering or not. In this case we need to render
      // empty bar or full progress bar with "launched" label.
      detailedProgress = notLaunchedDetailedProgress(activities)
    } else if (student.startedActivity) {
      detailedProgress = launchedDetailedProgress(activities)
    }

    return detailedProgress.map((details, idx) => (
      <td key={idx}>
        <ProgressBar student={student} detailedProgress={details} feedbackOptions={this.getFeedbackOptions(details.activityId)} />
      </td>
    ))
  }

  render () {
    const { students, activities } = this.props
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
              </tr>
              {
                students.map(student =>
                  <tr key={student.id}>
                    <td>{ this.renderStudentName(student) }</td>
                    <td className={css.date} title={student.lastRun && student.lastRun.toLocaleDateString()}>
                      { student.lastRun ? formatDate(student.lastRun) : 'n/a' }
                    </td>
                  </tr>
                )
              }
            </tbody>
          </table>
        </div>
        <div className={css.progressTableContainer}>
          <table className={css.progressTable}>
            <tbody>
              <tr>
                { activities.map((a, idx) => <th key={idx}>{ this.renderActivityHeader(a) }</th>) }
              </tr>
              {
                students.map(student =>
                  <tr key={student.id}>
                    { this.renderStudentProgressBars(student) }
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
