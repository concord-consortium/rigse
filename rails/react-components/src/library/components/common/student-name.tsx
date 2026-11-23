import React from "react";

interface StudentNameProps {
  name: string;
  isTeacherPreviewStudent?: boolean;
}

// Shows a student's name. For a teacher's learner mode account, adds " (LM)" after the name.
// The tooltip on "LM" tells the user what it means.
const StudentName: React.FC<StudentNameProps> = ({ name, isTeacherPreviewStudent }) => (
  <>
    { name }
    { isTeacherPreviewStudent && <> (<abbr title="Learner Mode user">LM</abbr>)</> }
  </>
);

export default StudentName;
