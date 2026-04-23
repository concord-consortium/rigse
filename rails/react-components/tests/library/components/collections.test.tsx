import React from "react";
import { render, screen } from "@testing-library/react";
import "@testing-library/jest-dom";

jest.mock("../../../src/library/components/stem-finder-result", () => {
  return function MockStemFinderResult ({ resource }: any) {
    return <div data-testid="stem-finder-result">{resource.name}</div>;
  };
});

import Collections from "../../../src/library/components/collections";

const makeCollections = (n: number) =>
  Array.from({ length: n }, (_, i) => ({
    name: `Collection ${i + 1}`,
    external_url: `https://example.com/c/${i + 1}`,
    material_type: "Collection"
  }));

describe("Collections", () => {
  it("shows initial 2 collections + Show More button when expandedByDefault is not set", () => {
    render(
      <Collections
        collections={makeCollections(5)}
        numTotalCollections={5}
        searching={false}
        showAllCollections={false}
        enableShowAllCollections={() => {}}
      />
    );
    expect(screen.getByText("Collection 1")).toBeInTheDocument();
    expect(screen.getByText("Collection 2")).toBeInTheDocument();
    expect(screen.queryByText("Collection 3")).not.toBeInTheDocument();
    expect(screen.getByRole("button", { name: /show more/i })).toBeInTheDocument();
  });

  it("renders all collections and hides Show More when expandedByDefault is true", () => {
    render(
      <Collections
        collections={makeCollections(5)}
        numTotalCollections={5}
        searching={false}
        showAllCollections={false}
        enableShowAllCollections={() => {}}
        expandedByDefault={true}
      />
    );
    expect(screen.getByText("Collection 1")).toBeInTheDocument();
    expect(screen.getByText("Collection 5")).toBeInTheDocument();
    expect(screen.queryByRole("button", { name: /show more/i })).not.toBeInTheDocument();
  });

  it("hides Show More when total fits within initial display count", () => {
    render(
      <Collections
        collections={makeCollections(2)}
        numTotalCollections={2}
        searching={false}
        showAllCollections={false}
        enableShowAllCollections={() => {}}
      />
    );
    expect(screen.queryByRole("button", { name: /show more/i })).not.toBeInTheDocument();
  });

  it("renders all collections when showAllCollections is true (post-click)", () => {
    render(
      <Collections
        collections={makeCollections(5)}
        numTotalCollections={5}
        searching={false}
        showAllCollections={true}
        enableShowAllCollections={() => {}}
      />
    );
    expect(screen.getByText("Collection 5")).toBeInTheDocument();
    expect(screen.queryByRole("button", { name: /show more/i })).not.toBeInTheDocument();
  });
});
