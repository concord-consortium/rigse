import React from "react";
import { CurrentSelectedProject } from "./types";

import css from "./classes-table.scss";

interface IProps {
  teacherId: string;
  currentSelectedProject: CurrentSelectedProject;
}

export const ClassesTable = ({ teacherId }: IProps) => {
  return (
    <table className={css.classesTable}>
      <thead>
        <tr><th>Class Name</th><th>Class Word</th><th></th></tr>
      </thead>
      <tbody>
      </tbody>
    </table>
  );
}
