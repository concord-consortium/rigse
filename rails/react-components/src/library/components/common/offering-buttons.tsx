import React from "react";
import { MakeTeacherEditionLink } from "../../helpers/make-teacher-edition-links";
import { logEvent } from "../../helpers/logger";

import commonCss from "../../styles/common-css-modules.scss";

export default class OfferingButtons extends React.Component<any, any> {
  render () {
    const { classHash } = this.props;
    const { id, activityName, previewUrl, activityUrl, hasTeacherEdition, reportUrl, externalReports } = this.props.offeringDetails;
    const activity = `activity: ${id}`;
    const parameters = {
      activityName,
      contextId: classHash
    };
    const previewLogData = {
      event: "clickedPreviewLink",
      event_value: previewUrl,
      activity,
      parameters
    };
    const teacherEditionLogData = {
      event: "clickedTeacherEditionLink",
      event_value: hasTeacherEdition && MakeTeacherEditionLink(activityUrl),
      activity,
      parameters
    };
    const reportLogData = {
      event: "clickedReportLink",
      event_value: reportUrl,
      activity,
      parameters
    };
    return (
      <>
        <a href={previewUrl} target="_blank" className={commonCss.smallButton} title="Preview" onClick={() => logEvent(previewLogData)} rel="noreferrer">Preview</a>
        {
          hasTeacherEdition &&
          <a href={MakeTeacherEditionLink(activityUrl)} target="_blank" className={"teacherEditionLink " + commonCss.smallButton} title="Teacher Edition" onClick={() => logEvent(teacherEditionLogData)} rel="noreferrer">Teacher Edition</a>
        }
        {
          reportUrl &&
          <a href={reportUrl} target="_blank" className={commonCss.smallButton} title="Report" onClick={() => logEvent(reportLogData)} rel="noreferrer">Report</a>
        }
        {
          externalReports?.map((externalReport: any, index: any) => {
            const externalReportLogData = {
              event: "clickedExternalReport",
              event_value: externalReport.url,
              activity,
              parameters
            };
            return (
              <a href={externalReport.url}
                key={index}
                target="_blank"
                className={commonCss.smallButton}
                onClick={() => logEvent(externalReportLogData)} rel="noreferrer">
                { externalReport.launchText }
              </a>
            );
          })
        }
      </>
    );
  }
}
