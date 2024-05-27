/* globals describe it expect */
import React from "react";
import { render, screen } from "@testing-library/react";
import StandardsTable, { PAGE_SIZE } from "../../../../src/library/components/standards/standards-table";

const material = {
  material_id: 1,
  material_type: "test-material-type",
};

const makeStatements = (count: any) => {
  const statements = [];
  for (let i = 0; i < count; i++) {
    statements.push({
      uri: `https://example.com/${i}`,
      is_applied: i === 1,
      is_leaf: i === 2,
      education_level: i === 3 ? [1, 2, 3] : [],
      doc: `doc ${i}`,
      description: `description ${i}`,
      statement_label: `statement_label ${i}`,
      statement_notation: `statement_notation ${i}`,
    });
  }
  return statements;
};

describe("When I try to render a standards table", () => {
  it("exports PAGE_SIZE", () => {
    expect(PAGE_SIZE).toBe(10);
  });

  describe("without pagination", () => {
    it("renders without pagination correctly", () => {
      const statements = makeStatements(2);
      render(<StandardsTable statements={statements} material={material} start={0} />);

      expect(screen.getByText("Type")).toBeInTheDocument();
      expect(screen.getByText("Description")).toBeInTheDocument();
      expect(screen.getByText("Label")).toBeInTheDocument();
      expect(screen.getByText("Notation")).toBeInTheDocument();
      expect(screen.getByText("URI")).toBeInTheDocument();
      expect(screen.getByText("Grades")).toBeInTheDocument();
      expect(screen.getByText("Leaf")).toBeInTheDocument();
      expect(screen.getByText("Action")).toBeInTheDocument();

      expect(screen.getByText("doc 0")).toBeInTheDocument();
      expect(screen.getByText("description 0")).toBeInTheDocument();
      expect(screen.getByText("statement_label 0")).toBeInTheDocument();
      expect(screen.getByText("statement_notation 0")).toBeInTheDocument();
      expect(screen.getAllByRole("link", { name: "🔗" })[0]).toHaveAttribute("href", "https://example.com/0");
      expect(screen.getByRole("button", { name: "Add" })).toBeInTheDocument();

      expect(screen.getByText("doc 1")).toBeInTheDocument();
      expect(screen.getByText("description 1")).toBeInTheDocument();
      expect(screen.getByText("statement_label 1")).toBeInTheDocument();
      expect(screen.getByText("statement_notation 1")).toBeInTheDocument();
      expect(screen.getAllByRole("link", { name: "🔗" })[1]).toHaveAttribute("href", "https://example.com/1");
      expect(screen.getByRole("button", { name: "Remove" })).toBeInTheDocument();
    });
  });
});
