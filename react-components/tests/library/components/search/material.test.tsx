import React from "react";
import { render, screen } from "@testing-library/react";
import SMaterial from "../../../../src/library/components/search/material";

describe("When I try to render search material", () => {
  it("should render with default props", () => {
    const material = {
      icon: {
        url: "http://example.com/icon"
      },
      links: {},
      material_properties: "",
      activities: []
    };
    render(<SMaterial material={material} />);

    expect(screen.getByRole("img", { name: "" })).toHaveAttribute("src", "http://example.com/icon");
    expect(screen.getByText("Runs in browser")).toBeInTheDocument();
    expect(screen.getByText("Community")).toBeInTheDocument();
    expect(screen.getByText("★")).toBeInTheDocument();
    expect(screen.getByText("☆")).toBeInTheDocument();
    expect(screen.getByText("Description")).toBeInTheDocument();
  });

  // TODO: add test for archive click

});
