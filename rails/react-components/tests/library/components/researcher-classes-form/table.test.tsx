import React from "react";
import { render, screen } from "@testing-library/react";
import "@testing-library/jest-dom";
import ResearcherClassesTable from "../../../../src/library/components/researcher-classes-form/table";

const row = (extra: any) => ({
  id: 1, name: "Class A", cohort_names: "Cohort", teacher_names: "T. Teacher", school_name: "School",
  materials_url: "/materials", roster_url: null, external_reports: [], ...extra
});

describe("ResearcherClassesTable", () => {
  it("links each class report by its launch text, or its name when that is blank", () => {
    render(<ResearcherClassesTable classes={[row({ external_reports: [
      { id: 7, name: "Dashboard", launch_text: "Researcher Dashboard", url: "/portal/classes/1/external_report/7?researcher=true" },
      { id: 8, name: "Other report", launch_text: "", url: "/portal/classes/1/external_report/8?researcher=true" }
    ] })]} />);
    expect(screen.getByRole("link", { name: "Researcher Dashboard" })).toHaveAttribute("href", "/portal/classes/1/external_report/7?researcher=true");
    expect(screen.getByRole("link", { name: "Other report" })).toHaveAttribute("href", "/portal/classes/1/external_report/8?researcher=true");
  });

  it("shows no report links for a row without any", () => {
    render(<ResearcherClassesTable classes={[row({})]} />);
    expect(screen.queryByRole("link", { name: "Researcher Dashboard" })).not.toBeInTheDocument();
    expect(screen.getByRole("link", { name: "View Assignments" })).toBeInTheDocument();
  });
});
