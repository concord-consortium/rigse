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
          <p><strong>Welcome! We're so glad you created a teacher account on our STEM Resource Finder!</strong></p>
          <p>It's time to add a class and assign activities to your students.</p>

          <p>To create a new class, click <strong>Add Class</strong> in the lefthand menu. Complete the fields and click <strong>Save Changes</strong>. For step-by-step instructions, please see our <a href="https://learn-resources.concord.org/docs/stem-resource-finder-teacher-user-guide/" target="_blank" rel="noreferrer">User Guide</a>.</p>

          <p>To assign materials, you have several options:</p>
          <ul>
            <li><span className={css.stepNumber}>1</span> Use the <strong>Find More Resources</strong> button when you are viewing Assignments.</li>
            <li><span className={css.stepNumber}>2</span> Browse a collection of related resources using the <a href="https://learn.concord.org/collections" target="_blank" rel="noreferrer">Collections</a> menu.</li>
            <li><span className={css.stepNumber}>3</span> Use the <a href="https://learn.concord.org/" target="_blank" rel="noreferrer">Find Resources</a> link, which takes you to the STEM Resource Finder homepage.</li>
          </ul>

          <p>When you find a resource you want to assign to your class, simply click the <strong>ASSIGN OR SHARE</strong> link.</p>

          <p><strong>Need a hand?</strong> Learn how to set up a class, assign resources, have your students register for your class, view student work, and more in the <a href="https://learn-resources.concord.org/docs/stem-resource-finder-teacher-user-guide/" target="_blank" rel="noreferrer">User Guide</a>. Or email us at <a href="mailto:help@concord.org">help@concord.org</a>.</p>
        </>
      );
    }
    if (anyData && !anyStudents) {
      return (
        <>
          <p className={css.noActivity}>No recent activity.</p>
          <p><strong>There are no students in your class.</strong> Please instruct your students to create an account on the STEM Resource Finder. After creating their account, they can join your class using a unique "class word" that you provide. For detailed instructions, please refer to the <a href="https://learn.concord.org/help" target="_blank" rel="noreferrer">User Guide</a>.
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
