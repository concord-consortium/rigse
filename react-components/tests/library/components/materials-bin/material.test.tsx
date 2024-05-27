import React from "react";
import { render, screen } from "@testing-library/react";
import MBMaterial from "../../../../src/library/components/materials-bin/material";

const material = {
  id: 1,
  name: "material 1",
  icon: {
    url: "http://example.com/icon",
  },
  links: {},
  material_properties: "",
  activities: [],
};

window.Portal = {
  currentUser: {
    isTeacher: true,
  },
};

describe("When I try to render materials-bin material", () => {
  it("should render with default props", () => {
    render(<MBMaterial material={material} />);

    const materialName = screen.getByText("material 1");
    const materialImage = screen.getByAltText("material 1");

    expect(materialName).toBeInTheDocument();
    expect(materialImage).toBeInTheDocument();
    expect(materialImage).toHaveAttribute("src", "http://example.com/icon");
  });
});
