import React from "react";
import { render, waitFor } from "@testing-library/react";
import StemFinderResult from "../../../src/library/components/stem-finder-result";
import { mockJquery } from "../helpers/mock-jquery";

describe("When a favorite change on a finder card is refused", () => {
  const message = "Cannot delete favorite not owned by current user.";
  const hint = "You may have switched to learner mode in another tab, so this page is out of date. Reload the page to continue.";

  mockJquery({
    post: jest.fn().mockImplementation(() => ({
      fail: (callback: any) => setTimeout(() => callback({ responseText: JSON.stringify({ message, learner_mode_hint: hint }) }))
    }))
  });

  const makeResource = (isFavorite: boolean) => ({
    id: 1,
    name: "Resource 1",
    material_type: "Activity",
    class_name_underscored: "external_activity",
    is_favorite: isFavorite,
    favorite_id: 2,
    stem_resource_url: "http://example.com/resource",
    filteredShortDescription: "",
    icon: { url: "http://example.com/icon" },
    links: { preview: { url: "http://example.com/preview", text: "Preview" } },
    projects: [],
    standard_statements: [],
    related_materials: [],
    assigned_classes: []
  });

  beforeEach(() => {
    window.Portal = { currentUser: { isLoggedIn: true, isTeacher: true } };
    (window as any).gtag = jest.fn();
    jest.spyOn(window, "alert").mockImplementation(() => undefined);
  });

  afterEach(() => {
    jest.restoreAllMocks();
  });

  it.each([
    ["adding", false],
    ["removing", true]
  ])("shows the server's message and does not change the star when %s fails", async (_action, isFavorite) => {
    const resource = makeResource(isFavorite);
    const { container } = render(<StemFinderResult resource={resource} index={0} />);
    const star = container.querySelector(".icon-favorite")!.parentElement!;
    const starClass = star.className;

    star.click();

    await waitFor(() => expect(window.alert).toHaveBeenCalledWith(`Unable to update favorite.\n${message}\n${hint}`));
    expect(resource.is_favorite).toBe(isFavorite);
    expect(star.className).toBe(starClass);
  });
});
