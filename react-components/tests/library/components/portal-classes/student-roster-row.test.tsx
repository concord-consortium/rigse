import React from 'react';
import { render, screen, fireEvent } from '@testing-library/react';
import '@testing-library/jest-dom';
// @ts-expect-error TS(2307): Cannot find module 'components/portal-classes/stud... Remove this comment to see the full error message
import StudentRosterRow from 'components/portal-classes/student-roster-row';

describe('When I try to render a student roster row', () => {

  const student = {
    name: "Test Testerson",
    username: "tester",
    last_login: "Last Tuesday",
    assignments_started: 2,
    can_remove: false,
    can_reset_password: false
  };

  it("should render with default parameters", () => {
    render(<table><tbody><StudentRosterRow student={student} /></tbody></table>);
    expect(screen.getByText('Test Testerson')).toBeInTheDocument();
    expect(screen.getByText('tester')).toBeInTheDocument();
    expect(screen.getByText('Last Tuesday')).toBeInTheDocument();
    expect(screen.getByText('2')).toBeInTheDocument();
  });

  it("should render in edit mode with no permissions", () => {
    render(<table><tbody><StudentRosterRow student={student} canEdit={true} /></tbody></table>);
    expect(screen.getByText('Test Testerson')).toBeInTheDocument();
    expect(screen.getByText('tester')).toBeInTheDocument();
    expect(screen.getByText('Last Tuesday')).toBeInTheDocument();
    expect(screen.getByText('2')).toBeInTheDocument();
    expect(screen.getByRole('cell', { name: '' })).toHaveClass('hide_in_print');
  });

  it("should render in edit mode with permissions", () => {
    const clonedStudent = { ...student, can_remove: true, can_reset_password: true };

    const removeStudent = jest.fn();
    const changePassword = jest.fn();

    render(<table><tbody><StudentRosterRow student={clonedStudent} canEdit={true} onRemoveStudent={removeStudent} onChangePassword={changePassword} /></tbody></table>);

    expect(screen.getByText('Test Testerson')).toBeInTheDocument();
    expect(screen.getByText('tester')).toBeInTheDocument();
    expect(screen.getByText('Last Tuesday')).toBeInTheDocument();
    expect(screen.getByText('2')).toBeInTheDocument();
    expect(screen.getByRole('cell', { name: /Remove Student/i })).toHaveClass('hide_in_print');
    expect(screen.getByRole('cell', { name: /Change Password/i })).toHaveClass('hide_in_print');

    const removeStudentLink = screen.getByText('Remove Student');
    const changePasswordLink = screen.getByText('Change Password');

    fireEvent.click(removeStudentLink);
    expect(removeStudent).toHaveBeenCalledWith(clonedStudent);
    expect(changePassword).not.toHaveBeenCalled();

    removeStudent.mockReset();

    fireEvent.click(changePasswordLink);
    expect(removeStudent).not.toHaveBeenCalled();
    expect(changePassword).toHaveBeenCalledWith(clonedStudent);
  });

});
