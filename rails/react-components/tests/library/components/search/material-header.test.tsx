import React from "react";
import { render, screen } from "@testing-library/react";
import SMaterialHeader from "../../../../src/library/components/search/material-header";

describe("When I try to render search material header", () => {

  it("should render with default props", () => {
    const material = {
      material_properties: "",
      publication_status: "published",
      links: {}
    };
    render(<SMaterialHeader material={material} />);

    expect(screen.getByText("Runs in browser")).toBeInTheDocument();
    expect(screen.getByText("Community")).toBeInTheDocument();
  });

  it("should render with optional props", () => {
    const material = {
      name: "material name",
      material_properties: "Requires download",
      is_official: true,
      publication_status: "draft",
      links: {
        browse: {
          url: "http://example.com/browse"
        },
        edit: {
          url: "http://example.com/edit",
          text: "edit text"
        }
      }
    };
    render(<SMaterialHeader material={material} />);

    expect(screen.getByText("Requires download")).toBeInTheDocument();
    expect(screen.getByText("Official")).toBeInTheDocument();
    expect(screen.getByText("draft")).toBeInTheDocument();
    expect(screen.getByText("material name")).toBeInTheDocument();
    expect(screen.getByText("edit text")).toBeInTheDocument();
  });

});
