import React from "react";
import { render, screen, fireEvent } from "@testing-library/react";
import ClassSetupForm from "../../../../src/library/components/portal-classes/setup-form";

describe("When I try to render class setup form", () => {
  const createProps = {
    portalClass: { teacher_id: 2 },
    portalClassGrades: [],
    portalClassTeacher: { name: "Joe Tester", id: 1 },
    teachers: {
      current: [{ name: "Tester, J. (joetester)", id: 1 }],
      unassigned: [],
    },
    errors: {},
    schools: [{ id: 1, name: "Example School" }],
    enableGradeLevels: true,
    activeGrades: [
      "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "Higher Ed",
    ],
    cancelLink: "https://example.com/home",
  };

  const editProps = {
    portalClass: {
      id: 5,
      teacher_id: 2,
      class_word: "testclass",
      name: "Test Class",
      description: "This is the test class",
    },
    portalClassGrades: ["1", "5", "9"],
    portalClassTeacher: { name: "Joe Tester", id: 1 },
    teachers: {
      current: [{ name: "Tester, J. (joetester)", id: 1 }],
      unassigned: [
        { name: "Bobberton, B. (bob)", id: 2 },
        { name: "Bar, F. (foobar)", id: 3 },
        { name: "Bang, B. (bazbang)", id: 4 },
      ],
    },
    errors: {},
    schools: [],
    enableGradeLevels: true,
    activeGrades: [
      "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "Higher Ed",
    ],
    cancelLink: "https://example.com/home",
  };

  it("should render in create mode", () => {
    render(<ClassSetupForm {...createProps} />);

    expect(screen.getByLabelText("Class Name:")).toBeInTheDocument();
    expect(screen.getByLabelText("Description:")).toBeInTheDocument();
    expect(screen.getByLabelText("Class Word:")).toBeInTheDocument();
    expect(screen.getByLabelText("School:")).toBeInTheDocument();
    expect(screen.getByText("Example School")).toBeInTheDocument();
    expect(screen.getByText("Grade Levels:")).toBeInTheDocument();
    expect(screen.getByText("Cancel")).toHaveAttribute("href", "https://example.com/home");
  });

  it("should render in edit mode", () => {
    render(<ClassSetupForm {...editProps} />);

    expect(screen.getByText("Teacher:")).toBeInTheDocument();
    expect(screen.getByText("Joe Tester")).toBeInTheDocument();
    expect(screen.getByText("testclass")).toBeInTheDocument();
    expect(screen.getByLabelText("Class Name:")).toHaveValue("Test Class");
    expect(screen.getByLabelText("Description:")).toHaveValue("This is the test class");
    expect(screen.getByText("Tester, J. (joetester)")).toBeInTheDocument();
    expect(screen.getByText("Bobberton, B. (bob)")).toBeInTheDocument();
    expect(screen.getByText("Bar, F. (foobar)")).toBeInTheDocument();
    expect(screen.getByText("Bang, B. (bazbang)")).toBeInTheDocument();
  });

  it("should allow adding and removing teachers", () => {
    render(<ClassSetupForm {...editProps} />);

    const addButton = screen.getByText("Add");
    const teacherList = screen.getByRole("list");

    expect(teacherList).toHaveTextContent("Tester, J. (joetester)");

    fireEvent.click(addButton);
    expect(teacherList).toHaveTextContent("Bobberton, B. (bob)");
    expect(teacherList).toHaveTextContent("Tester, J. (joetester)");

    const deleteIcons = screen.getAllByAltText(/Remove/);
    const savedConfirm = global.confirm;

    // simulate cancelling confirmation
    global.confirm = () => false;
    fireEvent.click(deleteIcons[0]);
    expect(teacherList).toHaveTextContent("Bobberton, B. (bob)");
    expect(teacherList).toHaveTextContent("Tester, J. (joetester)");

    // simulate accepting confirmation
    global.confirm = () => true;
    fireEvent.click(deleteIcons[0]);
    expect(teacherList).toHaveTextContent("Tester, J. (joetester)");

    global.confirm = savedConfirm;
  });
});
