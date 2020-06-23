import React from 'react'
import { RubricSummary } from '@concord-consortium/portal-report'
import Tooltip from 'rc-tooltip'
import 'rc-tooltip/assets/bootstrap.css'

import css from './style.scss'

const isPresent = val => val !== null && val !== undefined && val !== '' && JSON.stringify(val) !== '{}'

// Rubric icon is displayed inside progress bar. This constant defines what's the maximum number of rows
// that can be displayed without vertical scaling. When Rubric icon has more rows, it will be vertically scaled
// to fit progress bar height.
const MAX_RUBRIC_ROWS = 2

export default class Feedback extends React.Component {
  get feedbackEnabled () {
    const { options } = this.props
    return options.scoreFeedbackEnabled ||
           options.textFeedbackEnabled ||
           options.rubricFeedbackEnabled
  }

  get anyEnabledFeedbackAvailable () {
    const { feedback, options } = this.props
    if (!feedback) {
      return false
    }
    if (!feedback.hasBeenReviewed) {
      return false
    }
    return (options.scoreFeedbackEnabled && isPresent(feedback.score)) ||
           (options.textFeedbackEnabled && isPresent(feedback.textFeedback)) ||
           (options.rubricFeedbackEnabled && isPresent(feedback.rubricFeedback))
  }

  renderScore () {
    const { feedback, options } = this.props
    return options.scoreFeedbackEnabled && options.scoreType === 'manual' && isPresent(feedback.score) &&
      <span className={css.score}>{ feedback.score } of { options.maxScore }</span>
  }

  renderTextFeedback () {
    const { feedback, options } = this.props
    return options.textFeedbackEnabled && isPresent(feedback.textFeedback) &&
      <Tooltip placement='top' overlay={<div className={css.tooltipContent}>{ feedback.textFeedback }</div>}>
        <span className={css.textFeedbackIcon}>
          <span className='icon-bubble2' />
        </span>
      </Tooltip>
  }

  renderRubric () {
    const { feedback, options } = this.props
    if (!options.rubricFeedbackEnabled || !isPresent(feedback.rubricFeedback)) {
      return
    }
    const numberOfRows = options.rubric.criteria.length
    const scaling = `scale(1, ${Math.min(1, MAX_RUBRIC_ROWS / numberOfRows)})`
    return (
      <div className={css.rubricContainer} style={{ transform: scaling }}>
        <RubricSummary rubric={options.rubric} rubricFeedbacks={[ feedback.rubricFeedback ]} />
      </div>
    )
  }

  render () {
    if (!this.feedbackEnabled) {
      return null
    }
    if (!this.anyEnabledFeedbackAvailable) {
      return <span className={css.feedback}>needs feedback</span>
    }
    return (
      <span className={css.feedback}>
        { this.renderScore() }
        { this.renderTextFeedback() }
        { this.renderRubric() }
      </span>
    )
  }
}
