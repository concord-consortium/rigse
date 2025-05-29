import React from "react";

import TriStateCheckbox from "../tri-state-checkbox";

import css from "./style.scss";

const formatDate = (date: any) => `${date.getMonth() + 1}/${date.getDate()}/${date.getFullYear()}`;

export default class ProgressTableRow extends React.Component<any, any> {
  constructor (props: any) {
    super(props);
    this.onActiveUpdate = this.onActiveUpdate.bind(this);
    this.onLockedUpdate = this.onLockedUpdate.bind(this);
  }

  updateStudentMetadata(data: Record<string, any>) {
    const { student, offeringDetails, onSetStudentOfferingMetadata } = this.props;
    const dataWithUserId = { ...data, user_id: student.id };
    jQuery.ajax({
      type: "PUT",
      url: `/api/v1/offerings/${offeringDetails.id}/update_student_metadata`,
      data: dataWithUserId,
      success: (response: any) => {
        const active = response?.active ?? student.active;
        const locked = response?.locked ?? student.locked;
        const metadata = { active, locked };
        onSetStudentOfferingMetadata(student.id, offeringDetails.id, metadata);
      },
      error: () => {
        window.alert("Student metadata update failed, please try to reload page and try again.");
      }
    });
  }

  // note: when updating active or locked, we need to pass the other value as well
  // as it may be set based on the offering state in the UI and not yet set in the database
  onActiveUpdate(checked: boolean) {
    this.updateStudentMetadata({ active: checked, locked: this.props.student.locked });
  }

  onLockedUpdate(checked: boolean) {
    this.updateStudentMetadata({ locked: checked, active: this.props.student.active });
  }

  renderStudentName (student: any) {
    const name = <span className={css.name}>{ student.name }</span>;
    return student.reportUrl && student.totalProgress > 0
      ? <a href={student.reportUrl} target="_blank" title={`Open report for ${student.name}`} rel="noreferrer">{ name }</a>
      : name;
  }

  render () {
    const { student, offering } = this.props;
    return (
      <tr key={student.id}>
        <td>{ this.renderStudentName(student) }</td>
        <td className={css.date} title={student.lastRun?.toLocaleDateString()}>
          { student.lastRun ? formatDate(student.lastRun) : "n/a" }
        </td>
        <td className={css.status}>
          { student.startedActivity ? "Started" : "Not Started" }
        </td>
        {offering && <td><TriStateCheckbox checked={student.active} disabled={!offering.active} onChange={this.onActiveUpdate} /></td>}
        {offering && <td><TriStateCheckbox checked={student.locked} disabled={!offering.locked} onChange={this.onLockedUpdate} /></td>}
      </tr>
    );
  }
}
