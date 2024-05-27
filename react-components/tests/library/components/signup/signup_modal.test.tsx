/* globals describe it expect */
import React from "react";
import { render, screen } from "@testing-library/react";
import SignupModal from "../../../../src/library/components/signup/signup_modal";

describe("When I try to render signup modal", () => {
  it("should render", () => {
    render(<SignupModal />);

    expect(screen.getByText("Signing Up", { exact: false })).toBeInTheDocument();
    // @ts-expect-error TS(2769): No overload matches this call.
    expect(screen.getByRole("button", { name: "I am a Teacher", exact: false })).toBeInTheDocument();
    // @ts-expect-error TS(2769): No overload matches this call.
    expect(screen.getByRole("button", { name: "I am a Student", exact: false })).toBeInTheDocument();
    expect(screen.getByText("Already have an account?", { exact: false })).toBeInTheDocument();
    expect(screen.getByText("Log in »", { exact: false })).toBeInTheDocument();
    expect(screen.getByText("Why sign up?", { exact: false })).toBeInTheDocument();
    expect(screen.getByText("It's free and you get access to several key features, like creating classes for your students, assigning activities, saving work, tracking student progress, and more!", { exact: false })).toBeInTheDocument();
  });
});
