import React from "react";

interface StudentNameProps {
  name: string;
  isTeacherPreviewStudent?: boolean;
}

// "LM" marks a teacher's learner mode (teacher preview) account.
const StudentName: React.FC<StudentNameProps> = ({ name, isTeacherPreviewStudent }) => (
  <>
    { name }
    { isTeacherPreviewStudent && <> (<abbr title="Learner Mode user">LM</abbr>)</> }
  </>
);

export default StudentName;
