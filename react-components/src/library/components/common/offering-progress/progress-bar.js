import React from 'react'
import Feedback from './feedback'

import css from './style.scss'

export default class ProgressBar extends React.Component {
  constructor (props) {
    super(props)
    this.onClick = this.onClick.bind(this)
  }

  get clickable () {
    const { detailedProgress } = this.props
    return detailedProgress.reportUrl && detailedProgress.progress > 0
  }

  onClick () {
    if (!this.clickable) {
      return
    }
    const { detailedProgress } = this.props
    window.open(detailedProgress.reportUrl, '_blank')
  }

  render () {
    const { student, detailedProgress, feedbackOptions } = this.props
    return (
      <div className={`${css.progressBar}  ${this.clickable ? css.clickable : ''}`} onClick={this.onClick}
        title={`Open report for "${detailedProgress.activityName}" and ${student.name}`}>
        <div className={`${css.bar} ${detailedProgress.progress === 100 ? css.completed : ''}`}
          style={{ width: `${detailedProgress.progress}%` }} />
        <div className={css.textContainer}>
          {
            detailedProgress.info && <span className={css.textInfo}>{ detailedProgress.info }</span>
          }
          {
            detailedProgress.progress > 0 && feedbackOptions &&
            <Feedback feedback={detailedProgress.feedback} options={feedbackOptions} />
          }
        </div>
      </div>
    )
  }
}
