import React from "react";
import { render, screen } from "@testing-library/react";
import SMaterialInfo from "../../../../src/library/components/search/material-info";

describe("When I try to render search material info", () => {
  it("should render with default props", () => {
    const material = {
      links: {},
      material_properties: ""
    };
    render(<SMaterialInfo material={material} />);

    expect(screen.getByText("Runs in browser")).toBeInTheDocument();
    expect(screen.getByText("Community")).toBeInTheDocument();
  });

  it("should render with optional props #1", () => {
    const material = {
      name: "material name",
      material_properties: "Requires download",
      is_official: true,
      lara_activity_or_sequence: true,
      publication_status: "draft",
      parent: {
        type: "parent type",
        name: "parent name"
      },
      credits: "credits",
      assigned_classes: ["class 1"],
      links: {
        preview: {
          url: "http://example.com/preview",
          text: "preview text"
        },
        print_url: {
          url: "http://example.com/print_url",
          text: "print_url text"
        },
        external_lara_edit: {
          url: "http://example.com/external_lara_edit",
          text: "external_lara_edit text"
        },
        external_copy: {
          url: "http://example.com/external_copy",
          text: "external_copy text"
        },
        teacher_guide: {
          url: "http://example.com/teacher_guide",
          text: "teacher_guide text"
        },
        rubric_doc: {
          url: "http://example.com/rubric_doc",
          text: "rubric_doc text"
        },
        assign_material: {
          url: "http://example.com/assign_material",
          text: "assign_material text"
        },
        assign_collection: {
          url: "http://example.com/assign_collection",
          text: "assign_collection text"
        },
        unarchive: {
          url: "http://example.com/unarchive",
          text: "unarchive text"
        },
        browse: {
          url: "http://example.com/browse"
        },
        edit: {
          url: "http://example.com/edit",
          text: "edit text"
        },
        external_edit_iframe: {
          url: "http://example.com/external_edit_iframe",
          text: "external_edit_iframe text"
        }
      }
    };
    render(<SMaterialInfo material={material} />);

    expect(screen.getByText("Requires download")).toBeInTheDocument();
    expect(screen.getByText("Official")).toBeInTheDocument();
    expect(screen.getByText("draft")).toBeInTheDocument();
    expect(screen.getByText("material name")).toBeInTheDocument();
    expect(screen.getByText('from parent type "parent name"')).toBeInTheDocument();
    expect(screen.getByText("By credits")).toBeInTheDocument();
    expect(screen.getByText("(Assigned to class 1)")).toBeInTheDocument();
    expect(screen.getByRole("link", { name: "preview text" })).toHaveAttribute("href", "http://example.com/preview");
    expect(screen.getByRole("link", { name: "print_url text" })).toHaveAttribute("href", "http://example.com/print_url");
    expect(screen.getByRole("link", { name: "external_lara_edit text" })).toHaveAttribute("href", "http://example.com/external_lara_edit");
    expect(screen.getByRole("link", { name: "external_copy text" })).toHaveAttribute("href", "http://example.com/external_copy");
    expect(screen.getByRole("link", { name: "teacher_guide text" })).toHaveAttribute("href", "http://example.com/teacher_guide");
    expect(screen.getByRole("link", { name: "rubric_doc text" })).toHaveAttribute("href", "http://example.com/rubric_doc");
    expect(screen.getByRole("link", { name: "assign_material text" })).toHaveAttribute("href", "http://example.com/assign_material");
    expect(screen.getByRole("link", { name: "assign_collection text" })).toHaveAttribute("href", "http://example.com/assign_collection");
    expect(screen.getByRole("link", { name: "unarchive text" })).toHaveAttribute("href", "http://example.com/unarchive");
  });

  it("should render with optional props #2", () => {
    const material = {
      name: "material name",
      material_properties: "Requires download",
      is_official: true,
      lara_activity_or_sequence: false,
      publication_status: "draft",
      material_type: "Collection",
      links: {
        external_edit: {
          url: "http://example.com/external_edit",
          text: "external_edit text"
        },
        assign_material: {
          url: "http://example.com/assign_material",
          text: "assign_material text"
        }
      }
    };
    render(<SMaterialInfo material={material} />);

    expect(screen.getByText("Requires download")).toBeInTheDocument();
    expect(screen.getByText("Official")).toBeInTheDocument();
    expect(screen.getByText("draft")).toBeInTheDocument();
    expect(screen.getByText("material name")).toBeInTheDocument();
    expect(screen.getByRole("link", { name: "external_edit text" })).toHaveAttribute("href", "http://example.com/external_edit");
    expect(screen.queryByRole("link", { name: "assign_material text" })).not.toBeInTheDocument();
  });
});
