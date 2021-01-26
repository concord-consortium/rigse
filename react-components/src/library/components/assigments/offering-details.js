import React from 'react'
import OfferingProgress from '../common/offering-progress'
import { MakeTeacherEditionLink } from '../../helpers/make-teacher-edition-links'
import { logEvent } from '../../helpers/logger'

import css from './style.scss'
import commonCss from '../../styles/common-css-modules.scss'

// - log activity, activity name and context id [30m]
export default class OfferingDetails extends React.Component {
  render () {
    const { id, activityName, previewUrl, activityUrl, hasTeacherEdition, reportUrl, externalReports, students, reportableActivities } = this.props.offering
    const { classHash } = this.props.clazz
    // Activities listed in the progress table are either reportable activities or just the main offering.
    const progressTableActivities = reportableActivities || [{ id: 0, name: activityName, feedbackOptions: null }]
    const activity = `activity: ${id}`
    const parameters = {
      activityName: activityName,
      contextId: classHash
    }
    const previewLogData = {
      event: 'clickedPreviewLink',
      event_value: previewUrl,
      activity,
      parameters
    }
    const teacherEditionLogData = {
      event: 'clickedTeacherEditionLink',
      event_value: hasTeacherEdition && MakeTeacherEditionLink(activityUrl),
      activity,
      parameters
    }
    const reportLogData = {
      event: 'clickedReportLink',
      event_value: reportUrl,
      activity,
      parameters
    }
    return (
      <div className={css.offeringDetails}>
        <a href={previewUrl} target='_blank' className={commonCss.smallButton} title='Preview' onClick={() => logEvent(previewLogData)}>Preview</a>
        {
          hasTeacherEdition &&
          <a href={MakeTeacherEditionLink(activityUrl)} target='_blank' className={'teacherEditionLink ' + commonCss.smallButton} title='Teacher Edition' onClick={() => logEvent(teacherEditionLogData)}>Teacher Edition</a>
        }
        {
          reportUrl &&
          <a href={reportUrl} target='_blank' className={commonCss.smallButton} title='Report' onClick={() => logEvent(reportLogData)}>Report</a>
        }
        {
          externalReports && externalReports.map((externalReport, index) => {
            const externalReportLogData = {
              event: 'clickedExternalReport',
              event_value: externalReport.url,
              activity,
              parameters
            }
            return (
              <a href={externalReport.url}
                key={index}
                target='_blank'
                className={commonCss.smallButton}>
                onClick={() => logEvent(externalReportLogData)}
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
