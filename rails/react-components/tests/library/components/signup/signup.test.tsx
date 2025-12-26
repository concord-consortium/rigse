import React from "react";
import { render, screen, fireEvent } from "@testing-library/react";
import SignUp from "../../../../src/library/components/signup/signup";

describe("When I try to render signup student form", () => {
  it("should render with default props", () => {
    render(<SignUp />);

    expect(screen.getByText("Signing Up")).toBeInTheDocument();
    expect(screen.getByRole("button", { name: "I am a Teacher" })).toBeInTheDocument();
    expect(screen.getByRole("button", { name: "I am a Student" })).toBeInTheDocument();
    expect(screen.getByText("Already have an account?")).toBeInTheDocument();
    expect(screen.getByText("Why sign up?")).toBeInTheDocument();
  });

  it("should render with anonymous prop", () => {
    render(<SignUp anonymous={true} />);

    expect(screen.getByRole("button", { name: "I am a Teacher" })).toBeInTheDocument();
    expect(screen.getByRole("button", { name: "I am a Student" })).toBeInTheDocument();
    expect(screen.getByText("Already have an account?")).toBeInTheDocument();
    expect(screen.getByText("Why sign up?")).toBeInTheDocument();
  });

  it("should render teacher signup", () => {
    render(<SignUp anonymous={true} />);

    fireEvent.click(screen.getByRole("button", { name: "I am a Teacher" }));

    expect(screen.getByText("Create a Teacher Account")).toBeInTheDocument();
    expect(screen.getByText("First Name")).toBeInTheDocument();
    expect(screen.getByText("Last Name")).toBeInTheDocument();
    expect(screen.getByText("Password")).toBeInTheDocument();
    expect(screen.getByText("Confirm Password")).toBeInTheDocument();
    expect(screen.getByRole("button", { name: "Next" })).toBeInTheDocument();
  });

  it("should render student signup", () => {
    render(<SignUp anonymous={true} />);

    fireEvent.click(screen.getByRole("button", { name: "I am a Student" }));

    expect(screen.getByText("Create a Student Account")).toBeInTheDocument();
    expect(screen.getByText("First Name")).toBeInTheDocument();
    expect(screen.getByText("Last Name")).toBeInTheDocument();
    expect(screen.getByText("Password")).toBeInTheDocument();
    expect(screen.getByText("Confirm Password")).toBeInTheDocument();
    expect(screen.getByRole("button", { name: "Next" })).toBeInTheDocument();
  });
});
