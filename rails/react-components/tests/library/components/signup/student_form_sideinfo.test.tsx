import React from "react";
import { render, screen } from "@testing-library/react";
import StudentFormSideInfo from "../../../../src/library/components/signup/student_form_sideinfo";

describe("When I try to render signup student form sideinfo", () => {
  it("should render", () => {
    render(<StudentFormSideInfo />);
    expect(screen.getByText("Enter the class word your teacher gave you. If you don't know what the class word is, ask your teacher.")).toBeInTheDocument();
  });
});
