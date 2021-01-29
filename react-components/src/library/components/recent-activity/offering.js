import React from 'react'
import OfferingProgress from '../common/offering-progress/'
import OfferingButtons from '../common/offering-buttons'

import css from './style.scss'

export default class Offering extends React.Component {
  constructor (props) {
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
      completedStudentsCount, inProgressStudentsCount, notStartedStudentsCount } = this.props.offering
    const completedWidth = (completedStudentsCount / students.length) * 100
    const inProgressWidth = (inProgressStudentsCount / students.length) * 100
    const notStartedWidth = (notStartedStudentsCount / students.length) * 100
    // Activities listed in the progress table are either reportable activities or just the main offering.
    const progressTableActivities = reportableActivities || [{ id: 0, name: activityName, feedbackOptions: null }]
    return (
      <div className={css.offering}>
        <div>
          <span className={css.offeringHeader}>{clazz}: { activityName }</span>
          <a className={css.detailsToggle} onClick={this.toggleDetails}>{this.detailsToggleLabel}</a>
        </div>
        <div>
          <span>Class size = { students.length }</span>
          <div className={css.classProgress}>
            <div className={css.completed} style={{ width: `${completedWidth}%` }} >
              { completedStudentsCount > 0 && <div className={css.count}>{ completedStudentsCount }</div> }
            </div>
            <div className={css.inProgress} style={{ width: `${inProgressWidth}%` }} >
              { inProgressStudentsCount > 0 && <div className={css.count}>{ inProgressStudentsCount }</div> }
            </div>
            <div className={css.notStarted} style={{ width: `${notStartedWidth}%` }} >
              { notStartedStudentsCount > 0 && <div className={css.count}>{ notStartedStudentsCount }</div> }
            </div>
          </div>
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
