import React from 'react'
import OfferingProgress from '../common/offering-progress/'
import OfferingButtons from '../common/offering-buttons'

import css from './style.scss'

export default class Offering extends React.Component<any, any> {
  constructor (props: any) {
    super(props)
    this.state = {
      detailsVisible: false
    }
    this.toggleDetails = this.toggleDetails.bind(this)
  }

  get detailsToggleLabel () {
    const { detailsVisible } = this.state
    return detailsVisible ? '- HIDE DETAIL' : '+ SHOW DETAIL'
  }

  toggleDetails () {
    const { detailsVisible } = this.state
    this.setState({ detailsVisible: !detailsVisible })
  }

  render () {
    const { detailsVisible } = this.state
    const { clazz, classHash, activityName, students, reportableActivities,
      notStartedStudentsCount, startedStudentsCount } = this.props.offering

    // Activities listed in the progress table are either reportable activities or just the main offering.
    const progressTableActivities = reportableActivities || [{ id: 0, name: activityName, feedbackOptions: null }]
    return (
      <div className={css.offering}>
        <div>
          <span className={css.offeringHeader}>{clazz}: { activityName }</span>
          <a className={css.detailsToggle} onClick={this.toggleDetails}>{this.detailsToggleLabel}</a>
        </div>
        <div className={css.classProgress}>
          <span className={css.classSize}>Class size = { students.length }</span>
          <span>Started = { startedStudentsCount }</span>
          <span>Not Started = { notStartedStudentsCount }</span>

        </div>
        <div className={css.reports}>
          <OfferingButtons offering={this.props.offering} classHash={classHash} />
        </div>
        <div>
          { detailsVisible && <OfferingProgress activities={progressTableActivities} students={students} /> }
        </div>
      </div>
    )
  }
}
