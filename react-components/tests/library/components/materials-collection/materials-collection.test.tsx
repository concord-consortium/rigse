import React from "react";
import { render, screen } from "@testing-library/react";
import MaterialsCollection from "../../../../src/library/components/materials-collection/materials-collection";
import { mockJqueryAjaxSuccess } from "../../helpers/mock-jquery";

window.Portal = {
  API_V1: {
    MATERIALS_BIN_COLLECTIONS: "http://fake-url",
  },
};

const materials = [
  {
    id: 1,
    icon: {
      url: "http://example.com/icon",
    },
    links: {},
    material_properties: "",
    activities: [],
  },
  {
    id: 2,
    icon: {
      url: "http://example.com/icon",
    },
    links: {},
    material_properties: "",
    activities: [],
  },
];

mockJqueryAjaxSuccess([{ materials }]);

describe("When I try to render materials collection", () => {
  describe("with required props", () => {
    beforeEach(() => {
      render(
        <MaterialsCollection
          materials={materials}
          collection={1}
        />
      );
    });

    it("should call the ajax request", () => {
      expect(window.jQuery.ajax).toHaveBeenCalled();
    });

    it("should render the default props", () => {
      const materialItems = screen.getAllByRole("img");
      expect(materialItems).toHaveLength(2);
      expect(materialItems[0]).toHaveAttribute("src", "http://example.com/icon");
      expect(materialItems[1]).toHaveAttribute("src", "http://example.com/icon");
    });
  });

  describe("with optional props", () => {
    const onDataLoad = jest.fn();

    beforeEach(() => {
      render(
        <MaterialsCollection
          materials={materials}
          collection={1}
          header="this is the header"
          limit={2}
          onDataLoad={onDataLoad}
        />
      );
    });

    it("should call onDataLoad", () => {
      expect(onDataLoad).toHaveBeenCalledWith(materials);
    });

    it("should render the optional props", () => {
      const header = screen.getByRole("heading", { level: 1 });
      expect(header).toHaveTextContent("this is the header");

      const materialItems = screen.getAllByRole("img");
      expect(materialItems).toHaveLength(2);
      expect(materialItems[0]).toHaveAttribute("src", "http://example.com/icon");
      expect(materialItems[1]).toHaveAttribute("src", "http://example.com/icon");
    });
  });
});
