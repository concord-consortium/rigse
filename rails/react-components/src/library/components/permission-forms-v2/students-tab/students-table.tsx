import React from "react";
import { useFetch } from "../../../hooks/use-fetch";
import { CurrentSelectedProject, IStudent } from "./types";

import css from "./students-table.scss";

interface IProps {
  classId: string;
  currentSelectedProject: CurrentSelectedProject;
}

export const StudentsTable = ({ classId }: IProps) => {
  const { data: permissionFormsData, isLoading } = useFetch<IStudent[]>(Portal.API_V1.permissionFormsClassPermissionForms(classId), []);

  if (isLoading) {
    return (<div>Loading...</div>);
  }
  if (!permissionFormsData.length) {
    return (<div>No students found</div>);
  }

  return (
    <table className={css.studentsTable}>
      <thead>
        <tr><th><input type="checkbox" /></th><th>Student Name</th><th>Username</th><th>Permission Forms</th><th></th></tr>
      </thead>
      <tbody>
        {
          permissionFormsData.map((studentInfo) => {
            return (
              <tr key={studentInfo.id}>
                <td><input type="checkbox" /></td>
                <td>{ studentInfo.name }</td>
                <td>{ studentInfo.login }</td>
                <td>{ studentInfo.permission_forms.map(pf => pf.name).join(", ") }</td>
                <td><button className={css.basicButton}>Edit</button></td>
              </tr>
            );
          })
        }
      </tbody>
    </table>
  );
};
