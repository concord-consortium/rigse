import React from "react";

import ProgressTableRow from "./offering-progress-row";

import css from "./style.scss";

export default class ProgressTable extends React.Component<any, any> {
  getFeedbackOptions (activityId: any) {
    const { activities } = this.props;
    return activities.find((a: any) => a.id === activityId).feedbackOptions;
  }

  renderActivityHeader (act: any) {
    const name = <span className={css.activityTitle}>{ act.name }</span>;
    return act.reportUrl
      ? <a href={act.reportUrl} target="_blank" title={`Open report for "${act.name}"`} rel="noreferrer">{ name }</a>
      : name;
  }

  render () {
    const { students, offeringDetails, offering, onSetStudentOfferingMetadata } = this.props;
    if (students.length === 0) {
      return null;
    }
    return (
      <div className={css.offeringProgress}>
        <div className={css.namesTableContainer}>
          <table className={css.namesTable}>
            <tbody>
              {offering &&
                <tr className={css.studentSettingsHeader}>
                  <th />
                  <th />
                  <th />
                  <th colSpan={2}>Student Settings</th>
                </tr>
              }
              <tr>
                <th>Student</th>
                <th className={css.dateHeader}>Last Run</th>
                <th>Status</th>
                {offering && <th className={css.centered}>Visible</th>}
                {offering && <th className={css.centered}>Locked</th>}
              </tr>
              {
                students.map((student: any) => <ProgressTableRow student={student} offeringDetails={offeringDetails} offering={offering} onSetStudentOfferingMetadata={onSetStudentOfferingMetadata} key={student.id} />)
              }
            </tbody>
          </table>
        </div>
      </div>
    );
  }
}
