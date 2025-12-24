import React from "react";
import Offering from "./offering";

import css from "./style.scss";

export default class Offerings extends React.Component<any, any> {
  render () {
    const { anyClasses, offerings, anyData, anyStudents } = this.props;
    if (!anyClasses) {
      return (
        <>
          <p><strong>Welcome! We're so glad you created a teacher account on learn.concord.org!</strong> It's time to add a class and assign activities to your students.</p>

          <p>To create a new class, follow these steps:</p>
          <ul className={css.numberedStepsList}>
            <li><span className={css.stepNumber}>1</span> Click <strong>Add Class</strong> at the bottom of the menu on the left.</li>
            <li><span className={css.stepNumber}>2</span> Name your class.</li>
            <li><span className={css.stepNumber}>3</span> Optionally, give the class a short Description.</li>
            <li><span className={css.stepNumber}>4</span> Create a class word. The class word is a unique access code that allows students to join the class. <br />
              Our system is designed to prevent the occurrence of identical class words. Class words can be more than one word. They are not case sensitive. Do not include any special characters (e.g., *&@%!).
            </li>
            <li><span className={css.stepNumber}>5</span> Remember to write down your class word. Your students will use it to register themselves.</li>
            <li><span className={css.stepNumber}>6</span> Select the appropriate Grade Level(s) for your class.</li>
            <li><span className={css.stepNumber}>7</span> Click Save Changes.</li>
          </ul>

          <p><strong>Need a hand?</strong> Learn how to set up a class, assign resources, have your students register for your class, view student work, and more in the <a href="https://learn-resources.concord.org/docs/stem-resource-finder-teacher-user-guide/" target="_blank" rel="noreferrer">User Guide</a>. Or email us at <a href="mailto:help@concord.org">help@concord.org</a>.</p>
        </>
      );
    }
    if (!anyData) {
      return (
        <>
          <p className={css.noActivity}>No recent activity.</p>
          <p><strong>Now that you've created a class, you need to assign at least one activity to it.</strong> To assign materials, you have several options.</p>

          <ul className={css.numberedStepsList}>
            <li><span className={css.stepNumber}>1</span> Use the <strong>Find More Resources</strong> button when you are viewing Assignments.</li>
            <li><span className={css.stepNumber}>2</span> Browse a collection of related resources using the <a href="https://learn.concord.org/collections" target="_blank" rel="noreferrer">Collections</a> menu.</li>
            <li><span className={css.stepNumber}>3</span> Use the <a href="https://learn.concord.org/" target="_blank" rel="noreferrer">Find Resources</a> link, which takes you to the learn.concord.org homepage.</li>
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
          <p><strong>There are no students in your class.</strong> Please instruct your students to create an account on learn.concord.org. After creating their account, they can join your class using a unique "class word" that you provide. For detailed instructions, please refer to the <a href="https://learn.concord.org/help" target="_blank" rel="noreferrer">User Guide</a>.
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
