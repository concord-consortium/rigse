import React from 'react';
import { render, screen, fireEvent } from '@testing-library/react';
import '@testing-library/jest-dom';
// @ts-expect-error TS(2307): Cannot find module 'components/portal-classes/stud... Remove this comment to see the full error message
import StudentRoster from 'components/portal-classes/student-roster';

describe('When I try to render a student roster', () => {
  const students = [
    {
      student_id: 1,
      name: "Student 1",
      username: "s1",
      last_login: "Last Tuesday",
      assignments_started: 1,
      can_remove: true,
      can_reset_password: true
    },
    {
      student_id: 2,
      name: "Student 2",
      username: "s2",
      last_login: "Never",
      assignments_started: 2,
      can_remove: true,
      can_reset_password: true
    }
  ];

  const otherStudents = [
    {
      id: 3,
      name: "Student 3",
      username: "s3"
    },
    {
      id: 4,
      name: "Student 4",
      username: "s4"
    }
  ];

  it("should render with default parameters", () => {
    render(<StudentRoster canEdit={true} students={students} otherStudents={otherStudents} />);

    students.forEach(student => {
      expect(screen.getByText(student.name)).toBeInTheDocument();
      expect(screen.getByText(student.username)).toBeInTheDocument();
      expect(screen.getByText(student.last_login)).toBeInTheDocument();
      expect(screen.getByText(student.assignments_started.toString())).toBeInTheDocument();
    });

    const removeButtons = screen.getAllByText('Remove Student');
    const changePasswordButtons = screen.getAllByText('Change Password');

    expect(removeButtons.length).toBe(2);
    expect(changePasswordButtons.length).toBe(2);
  });

  it("should render the register another modal", () => {
    const savedLocation = window.location;
    // @ts-expect-error TS(2304): Cannot find name 'global'.
    delete global.window.location;
    // @ts-expect-error TS(2304): Cannot find name 'global'.
    global.window.location = {
      hash: "#registered_student"
    };

    render(<StudentRoster canEdit={true} students={students} otherStudents={otherStudents} />);

    expect(screen.getByText('Success! The student was registered and added to the class')).toBeInTheDocument();
    expect(screen.getByText('Do you wish to register and add another student?')).toBeInTheDocument();
    expect(screen.getByText('Add Another Student')).toBeInTheDocument();
    expect(screen.getByText('Cancel')).toBeInTheDocument();

    // @ts-expect-error TS(2304): Cannot find name 'global'.
    global.window.location = savedLocation;
  });

  // NOTE: the header and the rows are tested fully in their own component tests

});
