import React from "react";
import { render, screen, waitFor } from "@testing-library/react";
import FeaturedMaterials from "../../../../src/library/components/featured-materials/featured-materials";
import { mockJqueryAjaxSuccess } from "../../helpers/mock-jquery";

window.Portal = {
  API_V1: {
    MATERIALS_FEATURED: "http://fake-url",
  },
};

const materials = [
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
];

describe("When I try to render featured materials", () => {
  mockJqueryAjaxSuccess(materials);

  beforeEach(() => {
    jest.clearAllMocks();
  });

  it("should call jQuery.ajax", async () => {
    render(<FeaturedMaterials queryString="test" />);

    await waitFor(() => {
      expect(window.jQuery.ajax).toHaveBeenCalled();
    });
  });

  it("should render", async () => {
    render(<FeaturedMaterials queryString="test" />);

    await waitFor(() => {
      expect(screen.getByText("material 1")).toBeInTheDocument();
      expect(screen.getByText("material 2")).toBeInTheDocument();
    });

    const material1 = screen.getByText("material 1");
    const material2 = screen.getByText("material 2");

    expect(material1).toBeInTheDocument();
    expect(material2).toBeInTheDocument();

    const images = screen.getAllByRole("img");
    expect(images).toHaveLength(2);
    expect(images[0]).toHaveAttribute("src", "http://example.com/icon");
    expect(images[1]).toHaveAttribute("src", "http://example.com/icon");
  });
});
