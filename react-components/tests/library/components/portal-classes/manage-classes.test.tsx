import React from "react";
import { render, screen, fireEvent } from "@testing-library/react";
import ManageClasses from "../../../../src/library/components/portal-classes/manage-classes";
import { mockJqueryAjaxSuccess } from "../../helpers/mock-jquery";

describe("When I try to render manage classes", () => {
  mockJqueryAjaxSuccess({
    success: true,
  });

  const classes = [
    {
      id: 1,
      name: "test class 1",
      classWord: "test_class_1",
      description: "this is a test class 1",
      is_archived: false,
    },
    {
      id: 2,
      name: "test class 2",
      classWord: "test_class_2",
      description: "this is a test class 2",
      is_archived: true,
    },
    {
      id: 3,
      name: "test class 3",
      classWord: "test_class_3",
      description: "this is a test class 3",
      is_archived: false,
    },
  ];

  it("should render", () => {
    render(<ManageClasses classes={classes} />);

    expect(screen.getByText("My Classes (3 Total, 2 Active)")).toBeInTheDocument();
    expect(screen.getByText("test class 1")).toBeInTheDocument();
    expect(screen.getByText("test class 2")).toBeInTheDocument();
    expect(screen.getByText("test class 3")).toBeInTheDocument();
    expect(screen.getAllByText("Archive")).toHaveLength(2);
    expect(screen.getByText("Unarchive")).toBeInTheDocument();
    expect(screen.getAllByText("Copy")).toHaveLength(3);
  });

  it("should handle toggling activation", () => {
    render(<ManageClasses classes={classes} />);
    const toggleActiveButton = screen.getAllByText("Archive")[0];

    fireEvent.click(toggleActiveButton);
    expect(screen.getAllByText("Unarchive")[0]).toBeInTheDocument();

    fireEvent.click(screen.getAllByText("Unarchive")[0]);
    expect(screen.getAllByText("Archive")[0]).toBeInTheDocument();
  });

  it("should handle copying", () => {
    render(<ManageClasses classes={classes} />);
    const copyButton = screen.getAllByText("Copy")[0];

    expect(screen.queryByText("Copy Class")).not.toBeInTheDocument();
    fireEvent.click(copyButton);
    expect(screen.getByText("Copy Class")).toBeInTheDocument();
    expect(screen.getByDisplayValue("Copy of test class 1")).toBeInTheDocument();

    // NOTE: the copy dialog is tested in its own test file
  });
});
