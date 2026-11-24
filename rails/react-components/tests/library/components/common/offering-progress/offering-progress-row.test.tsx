import React from "react";
import { render, screen } from "@testing-library/react";
import "@testing-library/jest-dom";
import ProgressTableRow from "../../../../../src/library/components/common/offering-progress/offering-progress-row";
import { studentMapping } from "../../../../../src/library/components/common/offering-progress/helpers";

const apiStudent = {
  user_id: 1,
  name: "Student 123",
  first_name: "Test",
  last_name: "Teacher",
  started_activity: false,
  total_progress: 0,
  active: true,
  locked: false
};

const renderRow = (student: any) =>
  render(<table><tbody><ProgressTableRow student={student} /></tbody></table>);

describe("studentMapping", () => {
  it("maps is_teacher_preview_student to isTeacherPreviewStudent", () => {
    expect(studentMapping({ ...apiStudent, is_teacher_preview_student: true }).isTeacherPreviewStudent).toBe(true);
    expect(studentMapping({ ...apiStudent, is_teacher_preview_student: false }).isTeacherPreviewStudent).toBe(false);
  });
});

describe("ProgressTableRow", () => {
  it("does not mark a normal student", () => {
    renderRow(studentMapping({ ...apiStudent, is_teacher_preview_student: false }));
    expect(screen.getByRole("cell", { name: "Teacher, Test" })).toBeInTheDocument();
    expect(screen.queryByTitle("Learner Mode user")).not.toBeInTheDocument();
  });

  it("marks a teacher preview student with (LM) and a tooltip", () => {
    renderRow(studentMapping({ ...apiStudent, is_teacher_preview_student: true }));
    expect(screen.getByRole("cell", { name: /^Teacher, Test/ })).toHaveTextContent(/^Teacher, Test \(LM\)$/);
    expect(screen.getByTitle("Learner Mode user")).toHaveTextContent(/^LM$/);
  });

  it("marks a teacher preview student in the anonymized researcher view", () => {
    renderRow(studentMapping({ ...apiStudent, is_teacher_preview_student: true }, true));
    expect(screen.getByRole("cell", { name: /^Student 123/ })).toHaveTextContent(/^Student 123 \(LM\)$/);
  });

  it("marks a teacher preview student whose name links to a report", () => {
    renderRow(studentMapping({ ...apiStudent, is_teacher_preview_student: true, total_progress: 50, learner_report_url: "http://report" }));
    const link = screen.getByRole("link");
    expect(link).toHaveTextContent(/^Teacher, Test \(LM\)$/);
    expect(screen.getByTitle("Learner Mode user")).toBeInTheDocument();
  });
});
