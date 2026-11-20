import React from "react";
import { render, screen, fireEvent, waitFor } from "@testing-library/react";
import SMaterialIcon from "../../../../src/library/components/search/material-icon";
import { mockJquery } from "../../helpers/mock-jquery";

describe("When I try to render search material icon", () => {

  it("should render with default props", () => {
    const material = {
      icon: {
        url: "http://example.com/icon"
      },
      links: {}
    };
    const configuration = {};
    render(<SMaterialIcon material={material} configuration={configuration} />);

    const image = screen.getByRole("img");
    expect(image).toHaveAttribute("src", "http://example.com/icon");
    expect(image).toHaveAttribute("width", "100%");
  });

  it("should render with unstarred favorites props", () => {
    const material = {
      icon: {
        url: "http://example.com/icon"
      },
      links: {
        browse: {
          url: "http://example.com/browse"
        }
      }
    };
    const configuration = {
      enableFavorites: true,
      favoriteClassMap: {
        true: "legacy-favorite-active",
        false: "legacy-favorite"
      },
      favoriteOutlineClass: "legacy-favorite-outline",
      width: 100,
      height: 200
    };
    render(<SMaterialIcon material={material} configuration={configuration} />);

    const image = screen.getByRole("img");
    expect(image).toHaveAttribute("src", "http://example.com/icon");
    expect(image).toHaveAttribute("width", "100%");

    const thumbLink = screen.getByRole("link");
    expect(thumbLink).toHaveAttribute("href", "http://example.com/browse");

    const favorite = screen.getByText("★");
    const favoriteOutline = screen.getByText("☆");
    expect(favorite).toHaveClass("legacy-favorite");
    expect(favoriteOutline).toHaveClass("legacy-favorite legacy-favorite-outline");
  });

  it("should render with starred favorites props", () => {
    const material = {
      icon: {
        url: "http://example.com/icon"
      },
      links: {
        browse: {
          url: "http://example.com/browse"
        }
      },
      is_favorite: true
    };
    const configuration = {
      enableFavorites: true,
      favoriteClassMap: {
        true: "legacy-favorite-active",
        false: "legacy-favorite"
      },
      favoriteOutlineClass: "legacy-favorite-outline",
      width: 100,
      height: 200
    };
    render(<SMaterialIcon material={material} configuration={configuration} />);

    const image = screen.getByRole("img");
    expect(image).toHaveAttribute("src", "http://example.com/icon");
    expect(image).toHaveAttribute("width", "100%");

    const thumbLink = screen.getByRole("link");
    expect(thumbLink).toHaveAttribute("href", "http://example.com/browse");

    const favorite = screen.getByText("★");
    expect(favorite).toHaveClass("legacy-favorite legacy-favorite-active");
  });

});

describe("When a favorite change is refused", () => {
  const message = "You must be logged in as a teacher to favorite material. You may have switched to learner mode in another tab.";
  const configuration = {
    enableFavorites: true,
    favoriteClassMap: { true: "legacy-favorite-active", false: "legacy-favorite" },
    favoriteOutlineClass: "legacy-favorite-outline"
  };

  mockJquery({
    ajax: jest.fn().mockImplementation((options) => {
      setTimeout(() => options.error({ responseText: JSON.stringify({ message }) }));
    })
  });

  beforeEach(() => {
    window.Portal = {
      currentUser: { isTeacher: true },
      API_V1: { MATERIALS_ADD_FAVORITE: "/add_favorite", MATERIALS_REMOVE_FAVORITE: "/remove_favorite" }
    };
    jest.spyOn(window, "alert").mockImplementation(() => undefined);
  });

  afterEach(() => {
    jest.restoreAllMocks();
  });

  it("shows the server's message and does not change the favorite", async () => {
    const material = { id: 1, icon: { url: "http://example.com/icon" }, links: {}, is_favorite: false };
    render(<SMaterialIcon material={material} configuration={configuration} />);

    fireEvent.click(screen.getByText("☆"));

    await waitFor(() => expect(window.alert).toHaveBeenCalledWith(`Unable to update favorite.\n${message}`));
    expect(material.is_favorite).toBe(false);
  });
});
