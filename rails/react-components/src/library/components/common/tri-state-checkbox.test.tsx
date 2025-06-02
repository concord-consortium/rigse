import React from "react";
import { render, screen, fireEvent } from "@testing-library/react";
import "@testing-library/jest-dom";

import TriStateCheckbox from "./tri-state-checkbox";

describe("TriStateCheckbox", () => {
  it("renders with label", () => {
    render(
      <TriStateCheckbox
        checked={false}
        onChange={() => {}}
        label="Test Label"
      />
    );
    expect(screen.getByText("Test Label")).toBeInTheDocument();
  });

  it("fires onChange when clicked", () => {
    const handleChange = jest.fn();
    render(<TriStateCheckbox checked={false} onChange={handleChange} />);
    fireEvent.click(screen.getByRole("checkbox"));
    expect(handleChange).toHaveBeenCalledWith(true);
  });

  it("respects the disabled prop", () => {
    const handleChange = jest.fn();
    render(
      <TriStateCheckbox checked={false} onChange={handleChange} disabled={true} />
    );
    const checkbox = screen.getByRole("checkbox");
    expect(checkbox).toBeDisabled();
    fireEvent.click(checkbox);
    expect(handleChange).not.toHaveBeenCalled();
  });

  it("sets indeterminate and title when partiallyChecked is true", () => {
    render(
      <TriStateCheckbox
        checked={true}
        partiallyChecked={true}
        partiallyCheckedMessage="Partially selected"
        onChange={() => {}}
      />
    );

    const checkbox = screen.getByRole("checkbox");
    expect(checkbox).toHaveAttribute("title", "Partially selected");
    // Indeterminate is a property, not an attribute, must check it via DOM
    expect((checkbox as HTMLInputElement).indeterminate).toBe(true);
  });

  it("does not set indeterminate if partiallyChecked is false or checked is false", () => {
    render(
      <TriStateCheckbox
        checked={false}
        partiallyChecked={true}
        partiallyCheckedMessage="Partially selected"
        onChange={() => {}}
      />
    );

    const checkbox = screen.getByRole("checkbox");
    expect(checkbox).not.toHaveAttribute("title");
    expect((checkbox as HTMLInputElement).indeterminate).toBe(false);
  });

  it("renders with provided id", () => {
    render(<TriStateCheckbox checked={false} onChange={() => {}} id="my-id" />);
    expect(screen.getByRole("checkbox")).toHaveAttribute("id", "my-id");
  });
});
