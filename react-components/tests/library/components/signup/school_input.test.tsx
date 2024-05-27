/* globals describe it expect */
import React from "react";
import Formsy from "formsy-react";
import { render, screen } from "@testing-library/react";
import SchoolInput from "../../../../src/library/components/signup/school_input";

describe("When I try to render signup school input", () => {
  it("should render", () => {
    render(
      <Formsy>
        <SchoolInput name="test" />
      </Formsy>
    );

    expect(screen.getByRole("combobox")).toBeInTheDocument();
    expect(screen.getByText("Select...")).toBeInTheDocument();
  });
});
