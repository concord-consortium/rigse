import React from "react";
import { render, screen } from "@testing-library/react";
import SMaterialDetails from "../../../../src/library/components/search/material-details";

describe("When I try to render search material details", () => {

  it("should render with default props", () => {
    const material = {
      short_description: "short_description",
      activities: []
    };
    render(<SMaterialDetails material={material} />);

    expect(screen.getByText("Description")).toBeInTheDocument();
    expect(screen.getByText("short_description")).toBeInTheDocument();
    expect(screen.queryByText("Activities")).not.toBeInTheDocument();
  });

  it("should render with optional props", () => {
    const material = {
      short_description: "short_description",
      activities: [
        { id: 1, name: "activity 1" },
        { id: 2, name: "activity 2" }
      ],
      has_activities: true,
      has_pretest: true,
    };
    render(<SMaterialDetails material={material} />);

    expect(screen.getByText("Description")).toBeInTheDocument();
    expect(screen.getByText("short_description")).toBeInTheDocument();
    expect(screen.getByText("Pre- and Post-tests available.")).toBeInTheDocument();
    expect(screen.getByText("Activities")).toBeInTheDocument();
    expect(screen.getByText("activity 1")).toBeInTheDocument();
    expect(screen.getByText("activity 2")).toBeInTheDocument();
  });

});
