import React, { useState } from "react";
import clsx from "clsx";
import { useFetch } from "../../../hooks/use-fetch";
import { LinkButton } from "../common/link-button";
import { StudentsTable } from "./students-table";
import { CurrentSelectedProject, IClassBasicInfo } from "./types";

import css from "./classes-table.scss";

interface IProps {
  teacherId: number;
  currentSelectedProject: CurrentSelectedProject;
}

export const ClassesTable = ({ teacherId, currentSelectedProject }: IProps) => {
  const classesUrl = `${Portal.API_V1.teacherClasses(teacherId)}?include_archived=true`;
  const { data: classesData, isLoading } = useFetch<IClassBasicInfo[]>(classesUrl, []);
  const [selectedClassId, setSelectedClassId] = useState<number | null>(null);

  if (isLoading) {
    return (<div>Loading...</div>);
  }
  if (!classesData.length) {
    return (<div>No classes found</div>);
  }

  const handleViewStudentsClick = (classId: number) => {
    setSelectedClassId((prevSelectedClass: number | null) => prevSelectedClass === classId ? null : classId);
  };

  return (
    <table className={css.classesTable}>
      <thead>
        <tr><th>Class Name</th><th>Class Word</th><th>Class Status</th><th></th></tr>
      </thead>
      <tbody>
        {
          classesData.map((classInfo) => {
            const active = selectedClassId === classInfo.id;
            return (
              <React.Fragment key={classInfo.id}>
                <tr className={clsx({ [css.activeRow]: active })}>
                  <td>{ classInfo.name }</td>
                  <td>{ classInfo.class_word }</td>
                  <td>{ classInfo.is_archived ? "Archived" : "Active" }</td>
                  <td>
                    <LinkButton onClick={() => handleViewStudentsClick(classInfo.id)} active={active}>
                      {
                        active ? "Hide Students" : "Show Students"
                      }
                      {
                        active ? <i className="icon-caret-up" /> : <i className="icon-caret-down" />
                      }
                    </LinkButton>
                  </td>
                </tr>
                {
                  active &&
                  <tr>
                    <td colSpan={4} className={css.studentsTableRow}>
                      <StudentsTable classId={classInfo.id} currentSelectedProject={currentSelectedProject} />
                    </td>
                  </tr>
                }
              </React.Fragment>
            );
          })
        }
      </tbody>
    </table>
  );
};
