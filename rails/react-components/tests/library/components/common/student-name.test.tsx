import React from "react";
import { render, screen } from "@testing-library/react";
import "@testing-library/jest-dom";
import StudentName from "../../../../src/library/components/common/student-name";

describe("StudentName", () => {
  it("shows only the name for a normal student", () => {
    const { container } = render(<StudentName name="Student, Real" />);
    expect(container).toHaveTextContent(/^Student, Real$/);
    expect(container.querySelector("abbr")).toBeNull();
  });

  it("shows only the name when isTeacherPreviewStudent is false", () => {
    const { container } = render(<StudentName name="Student, Real" isTeacherPreviewStudent={false} />);
    expect(container).toHaveTextContent(/^Student, Real$/);
    expect(container.querySelector("abbr")).toBeNull();
  });

  it("adds (LM) with a tooltip for a teacher preview student", () => {
    const { container } = render(<StudentName name="Teacher, Test" isTeacherPreviewStudent={true} />);
    expect(container).toHaveTextContent(/^Teacher, Test \(LM\)$/);
    expect(screen.getByTitle("Learner Mode user")).toHaveTextContent(/^LM$/);
    expect(screen.getByTitle("Learner Mode user").tagName).toBe("ABBR");
  });

  it("adds (LM) to an anonymized name", () => {
    const { container } = render(<StudentName name="Student 123" isTeacherPreviewStudent={true} />);
    expect(container).toHaveTextContent(/^Student 123 \(LM\)$/);
  });
});
