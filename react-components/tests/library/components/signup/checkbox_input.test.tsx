/* globals describe it expect */
import React from "react";
import { render, screen } from "@testing-library/react";
import Formsy from "formsy-react";
import CheckboxInput from "../../../../src/library/components/signup/checkbox_input";

describe("When I try to render signup checkbox", () => {
  it("should render", () => {
    render(
      <Formsy>
        <CheckboxInput defaultChecked={true} name="_name" label="_label" />
      </Formsy>
    );

    const checkbox = screen.getByRole("checkbox", { name: "_label" });
    expect(checkbox).toBeInTheDocument();
    expect(checkbox).toBeChecked();

    const label = screen.getByLabelText("_label");
    expect(label).toBeInTheDocument();
  });
});
