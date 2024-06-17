import React, { useState } from "react";
import { useFetch } from "../../hooks/use-fetch";
import { IProject, CurrentSelectedProject } from "./permission-form-types";
import { ProjectSelect } from "./project-select";

import css from "./students-tab.scss";

export default function StudentsTab() {
  // Fetch projects (with refetch function) on initial load
  const { data: projectsData } = useFetch<IProject[]>(Portal.API_V1.PROJECTS_WITH_PERMISSIONS, []);

  // State for UI
  const [currentSelectedProject, setCurrentSelectedProject] = useState<number | "">("");

  const handleProjectSelectChange = (e: React.ChangeEvent<HTMLSelectElement>) => {
    setCurrentSelectedProject(e.target.value as CurrentSelectedProject);
  };

  const handleSearchClick = () => {};

  return (
    <div className={css.studentsTabContent}>
      <div className={css.controlsArea}>
        <div className={css.leftSide}>
          <div className={css.leftSideFirstRow}>
            <input type="text" />
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
    </div>
  );
}
