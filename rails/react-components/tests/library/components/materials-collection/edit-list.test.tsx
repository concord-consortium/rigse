import React from "react";
import { render, screen, fireEvent, waitFor } from "@testing-library/react";
import EditMaterialsCollectionList from "../../../../src/library/components/materials-collection/edit-list";
import { mockJqueryAjaxSuccess } from "../../helpers/mock-jquery";

const collection = {
  id: 1,
  name: "Test Materials Collection",
};

const singleItem = [
  {
    id: 1,
    name: "Material Collection Item",
    url: "/eresources/1",
    is_archived: false,
  },
];

const multipleItems = [
  {
    id: 1,
    name: "Material Collection Item #1",
    url: "/eresources/1",
    is_archived: false,
  },
  {
    id: 2,
    name: "Material Collection Item #2",
    url: "/eresources/2",
    is_archived: true,
  },
  {
    id: 3,
    name: "Material Collection Item #3",
    url: "/eresources/3",
    is_archived: false,
  },
];

mockJqueryAjaxSuccess({ success: true });

describe("When I try to render sortable material collection items", () => {
  const clone = (obj: any) => JSON.parse(JSON.stringify(obj));

  it("should render 0 items", () => {
    render(<EditMaterialsCollectionList collection={collection} items={[]} />);
    expect(screen.getByText(/No materials have been added to this collection/)).toBeInTheDocument();
  });

  it("should render 1 item", () => {
    render(<EditMaterialsCollectionList collection={collection} items={singleItem} />);
    expect(screen.getByText("Material Collection Item")).toBeInTheDocument();
  });

  it("should render multiple items", () => {
    render(<EditMaterialsCollectionList collection={collection} items={multipleItems} />);
    expect(screen.getByText("Material Collection Item #1")).toBeInTheDocument();
    expect(screen.getByText("Material Collection Item #2")).toBeInTheDocument();
    expect(screen.getByText("Material Collection Item #3")).toBeInTheDocument();
  });

  it("should handle the delete button", async () => {
    const { container } = render(<EditMaterialsCollectionList collection={collection} items={clone(singleItem)} />);
    const deleteButton = container.querySelector(".editMaterialsCollectionsListRowButtons button");

    // before delete
    expect(screen.getByText("Material Collection Item")).toBeInTheDocument();

    const savedConfirm = window.confirm;

    // with cancel on the confirmation
    window.confirm = () => false;
    fireEvent.click(deleteButton!);
    expect(screen.getByText("Material Collection Item")).toBeInTheDocument();

    // with ok on the confirmation
    window.confirm = () => true;
    fireEvent.click(deleteButton!);
    await waitFor(() => {
      expect(screen.getByText(/No materials have been added to this collection/)).toBeInTheDocument();
    });

    window.confirm = savedConfirm;
  });
});
