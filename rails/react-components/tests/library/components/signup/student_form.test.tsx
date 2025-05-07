import React from "react";
import { render, screen } from "@testing-library/react";
import StudentForm from "../../../../src/library/components/signup/student_form";

window.Portal = {
  API_V1: {
    CLASSWORD: "http://example.com/classword",
    STUDENTS: "http://example.com/students",
  }
};

describe("When I try to render signup student form", () => {
  it("should render", () => {
    render(<StudentForm />);
    expect(screen.getByText("Class Word")).toBeInTheDocument();
    expect(screen.getByPlaceholderText("Class Word (not case sensitive)")).toBeInTheDocument();
    expect(screen.getByText("By clicking \"Create Account!\", you agree to our", { exact: false })).toBeInTheDocument();
    expect(screen.getByRole("button", { name: "Create Account!" })).toBeInTheDocument();
  });
});
