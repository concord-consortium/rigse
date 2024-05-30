import React from "react";
import { render, screen, waitFor } from "@testing-library/react";
import MBCollections from "../../../../src/library/components/materials-bin/collections";
import { mockJqueryAjaxSuccess } from "../../helpers/mock-jquery";

const collections = [
  {
    name: "Collection Name",
    materials: [
      {
        id: 1,
        name: "material 1",
        icon: {
          url: "http://example.com/icon",
        },
        links: {},
        material_properties: "",
        activities: [],
      },
      {
        id: 2,
        name: "material 2",
        icon: {
          url: "http://example.com/icon",
        },
        links: {},
        material_properties: "",
        activities: [],
      },
    ],
  },
];

window.Portal = {
  API_V1: {
    MATERIALS_BIN_UNOFFICIAL_MATERIALS: "http://example.com",
  },
  currentUser: {
    isTeacher: false,
  },
};

describe("When I try to render materials-bin collections", () => {
  mockJqueryAjaxSuccess(collections);

  it("should render with default props", () => {
    render(<MBCollections />);

    expect(screen.getByText("loading")).toBeInTheDocument();
  });

  it("should render with visible props", async () => {
    render(<MBCollections visible={true} collections={collections} />);

    await waitFor(() => {
      expect(screen.getByText("Collection Name")).toBeInTheDocument();
      expect(screen.getByText("material 1")).toBeInTheDocument();
      expect(screen.getByText("material 2")).toBeInTheDocument();
    });

    const images = screen.getAllByRole("img");
    expect(images).toHaveLength(2);
    expect(images[0]).toHaveAttribute("src", "http://example.com/icon");
    expect(images[1]).toHaveAttribute("src", "http://example.com/icon");
  });
});
