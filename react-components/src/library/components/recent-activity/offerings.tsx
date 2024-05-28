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
          <p><strong>You have not yet added students to your classes.</strong> Have your students create student accounts on the site using your class's unique
            class word to enroll in your class. You can also manually register your students by clicking "Classes" on the left, then on the name of a class.
            Next click the "Student Roster" link for that class, and then on "Register &amp; Add a New Student."
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
