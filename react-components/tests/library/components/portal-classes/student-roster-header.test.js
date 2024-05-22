import React from 'react';
import { render, screen, fireEvent } from '@testing-library/react';
import '@testing-library/jest-dom';
import StudentRosterHeader from 'components/portal-classes/student-roster-header';

describe('When I try to render a student roster header', () => {

  it("should render with default parameters", () => {
    render(<StudentRosterHeader />);
    expect(screen.getByText("Please register students or have them self-register with the class word in order to add them to this class")).toBeInTheDocument();
    expect(screen.getByText("or")).toBeInTheDocument();
    expect(screen.getByRole("link", { name: /Register & Add New Student/i })).toBeInTheDocument();
  });

  const otherStudents = [
    { id: 1, name: "Student 1", username: "s1" },
    { id: 2, name: "Student 2", username: "s2" },
    { id: 3, name: "Student 3", username: "s3" }
  ];

  it("should render with students", () => {
    render(<StudentRosterHeader otherStudents={otherStudents} />);
    expect(screen.getByText("or")).toBeInTheDocument();
    expect(screen.getByRole("link", { name: /Register & Add New Student/i })).toBeInTheDocument();

    const select = screen.getByRole("combobox");
    expect(select).toBeInTheDocument();
    expect(select).toHaveValue("0");

    otherStudents.forEach(student => {
      expect(screen.getByText(`${student.name} (${student.username})`)).toBeInTheDocument();
    });

    expect(screen.getByRole("button", { name: /Add/i })).toBeDisabled();
  });

  it("should enable and disable the add button", () => {
    const addStudent = jest.fn();
    render(<StudentRosterHeader otherStudents={otherStudents} onAddStudent={addStudent} />);

    const addButton = screen.getByRole("button", { name: /Add/i });
    expect(addButton).toBeDisabled();

    fireEvent.change(screen.getByRole("combobox"), { target: { value: "1" } });
    expect(addButton).not.toBeDisabled();

    fireEvent.click(addButton);
    expect(addStudent).toHaveBeenCalledWith(otherStudents[0]);

    fireEvent.change(screen.getByRole("combobox"), { target: { value: "" } });
    expect(addButton).toBeDisabled();

    addStudent.mockReset();
    fireEvent.click(addButton);
    expect(addStudent).not.toHaveBeenCalled();
  });

  it("should handle the register & add new student action", () => {
    const registerStudent = jest.fn();
    render(<StudentRosterHeader onRegisterStudent={registerStudent} />);

    const registerLink = screen.getByRole("link", { name: /Register & Add New Student/i });
    fireEvent.click(registerLink);
    expect(registerStudent).toHaveBeenCalled();
  });

  it("should render with students with allowDefaultClass", () => {
    render(<StudentRosterHeader otherStudents={otherStudents} allowDefaultClass={true} />);
    expect(screen.getByText("If a student already has an account, ask the student to enter the Class Word above")).toBeInTheDocument();
    expect(screen.getByText("or")).toBeInTheDocument();
    expect(screen.getByRole("link", { name: /Register & Add New Student/i })).toBeInTheDocument();
  });
});
