/* globals describe it expect */
import React from "react";
import { render, screen } from "@testing-library/react";
import SMaterialsList from "../../../../src/library/components/search/materials-list";

describe("When I try to render search materials list", () => {
  it("should render with default props", () => {
    const materials = [{
      id: 1,
      icon: {
        url: "http://example.com/icon"
      },
      links: {},
      material_properties: "",
      activities: []
    }, {
      id: 2,
      icon: {
        url: "http://example.com/icon"
      },
      links: {},
      material_properties: "",
      activities: []
    }];

    render(<SMaterialsList materials={materials} />);

    const images = screen.getAllByRole("img", { name: "" });
    expect(images).toHaveLength(2);
    images.forEach(img => expect(img).toHaveAttribute("src", "http://example.com/icon"));

    const headers = screen.getAllByText("Runs in browser");
    expect(headers).toHaveLength(2);

    const communityTexts = screen.getAllByText("Community");
    expect(communityTexts).toHaveLength(2);

    const favoriteButtons = screen.getAllByText("★");
    expect(favoriteButtons).toHaveLength(2);

    const outlineFavoriteButtons = screen.getAllByText("☆");
    expect(outlineFavoriteButtons).toHaveLength(2);

    const descriptions = screen.getAllByText("Description");
    expect(descriptions).toHaveLength(2);
  });
});
