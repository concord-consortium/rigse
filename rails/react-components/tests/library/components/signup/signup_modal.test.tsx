import React from "react";
import { render, screen } from "@testing-library/react";
import SignupModal from "../../../../src/library/components/signup/signup_modal";

describe("When I try to render signup modal", () => {
  it("should render", () => {
    render(<SignupModal />);

    expect(screen.getByText("Signing Up", { exact: false })).toBeInTheDocument();
    expect(screen.getByRole("button", { name: "I am a Teacher" })).toBeInTheDocument();
    expect(screen.getByRole("button", { name: "I am a Student" })).toBeInTheDocument();
    expect(screen.getByText("Already have an account?", { exact: false })).toBeInTheDocument();
    expect(screen.getByText("Log in »", { exact: false })).toBeInTheDocument();
    expect(screen.getByText("Why sign up?", { exact: false })).toBeInTheDocument();

    // Check if the login option paragraph with the login link is rendered
    expect(screen.getByText("Already have an account?")).toBeInTheDocument();
    expect(screen.getByRole("link", { name: /Log in »/i })).toBeInTheDocument();
  });
});
