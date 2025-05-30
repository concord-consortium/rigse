import React from "react";
import { render, screen } from "@testing-library/react";
import UserTypeSelector from "../../../../src/library/components/signup/user_type_selector";

describe("When I try to render signup user type selector", () => {

  it("should render", () => {
    render(<UserTypeSelector />);

    // Check if the teacher button is rendered
    expect(screen.getByRole("button", { name: /I am a Teacher/i })).toBeInTheDocument();
    // Check if the student button is rendered
    expect(screen.getByRole("button", { name: /I am a Student/i })).toBeInTheDocument();
  });

});
