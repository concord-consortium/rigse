import React, { useState } from "react";
import clsx from "clsx";
import { useFetch } from "../../../hooks/use-fetch";
import { IProject, CurrentSelectedProject, ITeacher } from "./types";
import { ProjectSelect } from "../common/project-select";
import { request } from "../../../helpers/api/request";
import { LinkButton } from "../common/link-button";
import { ClassesTable } from "./classes-table";

import css from "./students-tab.scss";

// This param is used mostly for testing purposes. It allows to set a custom limit for the number of results,
// so staging environments can test how the search behaves when limit is reached.
const getTeachersLimit = () => {
  const urlParams = new URLSearchParams(window.location.search);
  return urlParams.get("teachersLimit") || 50;
};

const searchTeachers = async (name: string) =>
  request({
    url: Portal.API_V1.permissionFormsSearchTeacher(name, getTeachersLimit()),
    method: "GET"
  });

export default function StudentsTab() {
  // Fetch projects (with refetch function) on initial load
  const { data: projectsData } = useFetch<IProject[]>(Portal.API_V1.PERMISSION_FORMS_PROJECTS, []);
  // `null` means no search has been done yet, while an empty array means no results were found.
  const [teachers, setTeachers] = useState<ITeacher[] | null>(null);
  const [teachersLimitApplied, setTeachersLimitApplied] = useState<boolean>(false);
  const [selectedTeacherId, setSelectedTeacherId] = useState<string | null>(null);
  const[teacherName, setTeacherName] = useState<string>("");

  // State for UI
  const [currentSelectedProject, setCurrentSelectedProject] = useState<number | "">("");

  const handleProjectSelectChange = (e: React.ChangeEvent<HTMLSelectElement>) => {
    setCurrentSelectedProject(e.target.value as CurrentSelectedProject);
  };

  const handleTeacherNameChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    setTeacherName(e.target.value);
  };

  const handleSearchClick = async () => {
    setSelectedTeacherId(null);
    const { teachers, limit_applied } = await searchTeachers(teacherName);
    setTeachers(teachers);
    setTeachersLimitApplied(limit_applied);
  };

  const handleViewClassesClick = (teacherId: string) => {
    setSelectedTeacherId((prevSelectedTeacher: string | null) => prevSelectedTeacher === teacherId ? null : teacherId);
  };

  return (
    <div className={css.studentsTabContent}>
      <div className={css.controlsArea}>
        <div className={css.leftSide}>
          <div className={css.leftSideFirstRow}>
            <input type="text" value={teacherName} onChange={handleTeacherNameChange} />
            <button onClick={handleSearchClick}>Search</button>
          </div>
          <div>
            search for teachers by firstname, lastname, login, or email.
          </div>
        </div>
        <div className={css.rightSide}>
          <div className={css.title}>Filter permission forms by:</div>
          <div>
            <ProjectSelect projects={projectsData} value={currentSelectedProject} onChange={handleProjectSelectChange} />
          </div>
        </div>
      </div>
      {
        teachers && teachers.length === 0 &&
        <div className={css.searchResultsNotice}>No teachers found.</div>
      }
      {
        teachersLimitApplied &&
        <div className={css.searchResultsNotice}>
          Search results have been limited to {getTeachersLimit()} teachers. Please refine your search.
        </div>
      }
      {
        teachers && teachers.length > 0 &&
        <table className={css.teachersTable}>
          <thead>
            <tr><th>Teacher Name</th><th>Teacher Email</th><th>Teacher Login</th><th className={css.expandButton} /></tr>
          </thead>
          <tbody>
            {
              teachers.map((teacher, idx) => {
                const active = selectedTeacherId === teacher.id;
                // Typical pattern with CSS nth-child won't work, as we inject additional row when user expands a teacher.
                const background = idx % 2 === 1;
                return (
                  <React.Fragment key={teacher.id}>
                    <tr className={clsx({ [css.activeRow]: active, [css.rowWithBackground]: background })}>
                      <td>{ teacher.name }</td>
                      <td>{ teacher.email }</td>
                      <td>{ teacher.login }</td>
                      <td className={css.expandButton}>
                        <LinkButton onClick={() => handleViewClassesClick(teacher.id)} active={active}>
                          {
                            active ? "Hide Classes" : "Show Classes"
                          }
                          {
                            active ? <i className="icon-caret-up" /> : <i className="icon-caret-down" />
                          }
                        </LinkButton>
                      </td>
                    </tr>
                    {
                      active &&
                      <tr className={clsx({ [css.rowWithBackground]: background })}>
                        <td colSpan={4} className={css.classesTableRow}>
                          <ClassesTable teacherId={teacher.id} currentSelectedProject={currentSelectedProject} />
                        </td>
                      </tr>
                    }
                  </React.Fragment>
                );
              })
            }
          </tbody>
        </table>
      }
    </div>
  );
}
