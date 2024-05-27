import React from "react";
import { render, screen } from "@testing-library/react";
import SearchResults from "../../../../src/library/components/search/results";
import { mockJquery } from "../../helpers/mock-jquery";

describe("When I try to render search results", () => {
  mockJquery(() => ({
    paging: jest.fn()
  }));

  it("should render with default props", () => {
    const results: any = [];
    render(<SearchResults results={results} />);

    const offeringList = screen.getByTestId("offering-list");
    expect(offeringList).toBeInTheDocument();

    const resultsMessage = screen.getByText(/matching selected criteria/i);
    expect(resultsMessage).toBeInTheDocument();

    const resultsContainer = screen.getByTestId("results-container");
    expect(resultsContainer).toBeInTheDocument();
  });

  it("should render with results", () => {
    const results = [{
      type: "investigations",
      pagination: {
        total_items: 10,
        per_page: 20,
        start_item: 1,
        end_item: 20
      },
      materials: []
    }];

    render(<SearchResults results={results} />);

    expect(screen.getByTestId("offering-list")).toBeInTheDocument();

    expect(screen.getByText("matching selected criteria")).toBeInTheDocument();

    expect(screen.getByTestId("results-container")).toBeInTheDocument();

    expect(screen.getByText("all 10")).toBeInTheDocument();
  });
});
