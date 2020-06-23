import React from 'react'
import OfferingProgress from '../common/offering-progress'
import { MakeTeacherEditionLink } from '../../helpers/make-teacher-edition-links'
import css from './style.scss'
import commonCss from '../../styles/common-css-modules.scss'

export default class OfferingDetails extends React.Component {
  render () {
    const { activityName, previewUrl, activityUrl, hasTeacherEdition, reportUrl, externalReports, students, reportableActivities } = this.props.offering
    // Activities listed in the progress table are either reportable activities or just the main offering.
    const progressTableActivities = reportableActivities || [{ id: 0, name: activityName, feedbackOptions: null }]
    return (
      <div className={css.offeringDetails}>
        <a href={previewUrl} target='_blank' className={commonCss.smallButton} title='Preview'>Preview</a>
        {
          hasTeacherEdition &&
          <a href={MakeTeacherEditionLink(activityUrl)} target='_blank' className={'teacherEditionLink ' + commonCss.smallButton} title='Teacher Edition'>Teacher Edition</a>
        }
        {
          reportUrl &&
          <a href={reportUrl} target='_blank' className={commonCss.smallButton} title='Report'>Report</a>
        }
        {
          externalReports && externalReports.map((externalReport, index) => {
            return (
              <a href={externalReport.url}
                key={index}
                target='_blank'
                className={commonCss.smallButton}>
                { externalReport.launchText }
              </a>
            )
          })
        }
        <div className={css.progressContainer}>
          <OfferingProgress activities={progressTableActivities} students={students} />
        </div>
      </div>
    )
  }
}
