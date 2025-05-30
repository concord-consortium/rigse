import React from "react";
import OfferingProgress from "../common/offering-progress";
import OfferingButtons from "../common/offering-buttons";

import css from "./style.scss";

export default class OfferingDetails extends React.Component<any, any> {
  render () {
    const { offeringDetails, clazz, onSetStudentOfferingMetadata, offering } = this.props;
    const { activityName, students, reportableActivities } = offeringDetails;
    // Activities listed in the progress table are either reportable activities or just the main offering.
    const progressTableActivities = reportableActivities || [{ id: 0, name: activityName, feedbackOptions: null }];
    return (
      <div className={css.offeringDetails}>
        <OfferingButtons offeringDetails={offeringDetails} classHash={clazz.classHash} />
        <div className={css.progressContainer}>
          <OfferingProgress
            activities={progressTableActivities}
            students={students}
            offeringDetails={offeringDetails}
            offering={offering}
            onSetStudentOfferingMetadata={onSetStudentOfferingMetadata}
          />
        </div>
      </div>
    );
  }
}
