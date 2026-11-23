import React from "react";
import { render, screen } from "@testing-library/react";
import "@testing-library/jest-dom";
import { StudentsTable } from "../../../../src/library/components/permission-forms/students-tab/students-table";
import { useFetch } from "../../../../src/library/hooks/use-fetch";

jest.mock("../../../../src/library/hooks/use-fetch");

window.Portal = {
  API_V1: {
    PERMISSION_FORMS: "/api/v1/permission_forms",
    permissionFormsClassPermissionForms: (classId: number) => `/api/v1/permission_forms/class_permission_forms?class_id=${classId}`
  }
};

describe("StudentsTable", () => {
  beforeEach(() => {
    const students = [
      { id: 1, name: "Real Student", login: "rstudent", is_teacher_preview_student: false, permission_forms: [] },
      { id: 2, name: "Test Teacher", login: "tteacher", is_teacher_preview_student: true, permission_forms: [] }
    ];
    (useFetch as jest.Mock).mockImplementation((url: string) => {
      if (url === window.Portal.API_V1.PERMISSION_FORMS) {
        return { data: [], isLoading: false, refetch: jest.fn() };
      }
      return { data: students, isLoading: false, refetch: jest.fn() };
    });
  });

  it("marks only the teacher preview student with (LM) and a tooltip", () => {
    render(<StudentsTable classId={1} currentSelectedProject={null} />);

    const normalRow = screen.getByText("rstudent").closest("tr") as HTMLElement;
    const previewRow = screen.getByText("tteacher").closest("tr") as HTMLElement;

    expect(normalRow.querySelectorAll("td")[1]).toHaveTextContent(/^Real Student$/);
    expect(previewRow.querySelectorAll("td")[1]).toHaveTextContent(/^Test Teacher \(LM\)$/);

    const tooltips = screen.getAllByTitle("Learner Mode user");
    expect(tooltips).toHaveLength(1);
    expect(previewRow).toContainElement(tooltips[0]);
  });
});
