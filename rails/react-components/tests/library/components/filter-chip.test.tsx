import * as React from "react";
import { render, screen, fireEvent } from "@testing-library/react";
import { FilterChip } from "../../../src/library/components/filter-chip";

describe("FilterChip", () => {
  it("renders the label text", () => {
    render(<FilterChip label="Chemistry" onRemove={() => { /* noop */ }} />);
    expect(screen.getByText("Chemistry")).toBeInTheDocument();
  });

  it("exposes a button whose accessible name identifies which filter it removes", () => {
    render(<FilterChip label="Chemistry" onRemove={() => { /* noop */ }} />);
    expect(
      screen.getByRole("button", { name: /Remove filter: Chemistry/i })
    ).toBeInTheDocument();
  });

  it("fires onRemove when the X button is clicked", () => {
    const onRemove = jest.fn();
    render(<FilterChip label="Chemistry" onRemove={onRemove} />);
    fireEvent.click(screen.getByRole("button", { name: /Remove filter: Chemistry/i }));
    expect(onRemove).toHaveBeenCalledTimes(1);
  });

  it("keeps the label text quoted verbatim (used for keyword chips)", () => {
    render(<FilterChip label={`"earthquakes"`} onRemove={() => { /* noop */ }} />);
    expect(screen.getByText(`"earthquakes"`)).toBeInTheDocument();
  });
});
