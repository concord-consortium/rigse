import React from 'react'
import OfferingProgress from '../common/offering-progress'
import OfferingButtons from '../common/offering-buttons'

import css from './style.scss'

export default class OfferingDetails extends React.Component {
  render () {
    const { activityName, students, reportableActivities } = this.props.offering
    // Activities listed in the progress table are either reportable activities or just the main offering.
    const progressTableActivities = reportableActivities || [{ id: 0, name: activityName, feedbackOptions: null }]
    return (
      <div className={css.offeringDetails}>
        <OfferingButtons offering={this.props.offering} classHash={this.props.clazz.classHash} />
        <div className={css.progressContainer}>
          <OfferingProgress activities={progressTableActivities} students={students} />
        </div>
      </div>
    )
  }
}
