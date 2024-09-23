import React from "react";
import Offering from "./offering";

import css from "./style.scss";

export default class Offerings extends React.Component<any, any> {
  render () {
    const { anyClasses, offerings, anyData, anyStudents } = this.props;
    if (!anyClasses) {
      return (
        <>
          <p>To get started, add a new class by clicking "Classes" on the left and then "Add Class." Enter the class setup information, including class name,
            description, applicable grade level(s), and specify a unique class word. Students will use the unique class word to enroll in the class.
          </p>
          <p>You can then assign activities to the class. As your students enroll and get started, their progress will be displayed here.</p>
        </>
      );
    }
    if (!anyData) {
      return (
        <>
          <p className={css.noActivity}>No recent activity.</p>
          <p><strong>You need to assign at least one activity to your classes.</strong> To add an assignment, click "Classes" on the left, then on the name of
            a class. Next click the "Assignments" link for that class, and then the "Find More Resources" button to view assignable activities.
          </p>
          <p>As your students get started on assigned activities, their progress will be displayed here.</p>
        </>
      );
    }
    if (anyData && !anyStudents) {
      return (
        <>
          <p className={css.noActivity}>No recent activity.</p>
          <p><strong>There are no students in your class.</strong>
          Please instruct your students to create an account on the STEM Resource Finder. After creating their account, they can join your class using a unique "class word" that you provide. For detailed instructions, please refer to the <a href="https://learn.concord.org/help" target="_blank" rel="noreferrer">User Guide</a>.
          </p>
          <p>As your students register and get started on the assigned activities, their progress will be displayed here.</p>
        </>
      );
    }
    if (offerings.length === 0) {
      return (
        <>
          <p className={css.noActivity}>No recent activity.</p>
          <p>As your students get started on assigned activities, their progress will be displayed here.</p>
        </>
      );
    }
    return (
      <>
        { offerings.map((offering: any) => <Offering key={offering.id} offering={offering} />) }
      </>
    );
  }
}
