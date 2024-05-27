import React from "react";
import { render, screen } from "@testing-library/react";
import SPaginationInfo from "../../../../src/library/components/search/pagination-info";

describe("When I try to render search pagination info", () => {
  it("should render with total_items <= per_page", () => {
    const info = {
      total_items: 10,
      per_page: 20,
      start_item: 1,
      end_item: 20
    };
    render(<SPaginationInfo info={info} />);
    expect(screen.getByText("Displaying")).toBeInTheDocument();
    expect(screen.getByText("all 10")).toBeInTheDocument();
  });
});
