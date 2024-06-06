import React, { useState } from "react";
import { useFetch } from "../../hooks/use-fetch";
import { CreateNewPermissionForm } from "./create-new-permission-form";
import PermissionFormRow from "./permission-form-row";
import { IPermissionForm, IProject, CurrentSelectedProject } from "./permission-form-types";

import css from "./style.scss";

export default function PermissionFormsV2() {
  // Fetch projects and permission forms (with refetch function) on initial load
  const { data: permissionsData, refetch: refetchPermissions } = useFetch<IPermissionForm[]>(Portal.API_V1.PERMISSION_FORMS, []);
  const { data: projectsData } = useFetch<IProject[]>(Portal.API_V1.PROJECTS, []);

  // State for UI
  const [showForm, setShowForm] = useState(false);
  const [currentSelectedProject, setCurrentSelectedProject] = useState<number | "">("");

  const handleProjectSelectChange = (e: React.ChangeEvent<HTMLSelectElement>) => {
    setCurrentSelectedProject(e.target.value as CurrentSelectedProject);
  };

  const handleFormSave = (newForm: IPermissionForm) => {
    setCurrentSelectedProject(newForm.project_id as CurrentSelectedProject);
    setShowForm(false);
    refetchPermissions();
  };

  const getFilteredForms = () => {
    const belongsToSelectedProject = (form: IPermissionForm) => form.project_id === Number(currentSelectedProject);
    return currentSelectedProject === ""
      ? permissionsData
      : permissionsData?.filter(belongsToSelectedProject);
  };

  return (
    <div className={css.permissionForms}>
      <div className={css.tableAndControls}>
        <h2>Permission Form Options</h2>
        <p>Tabs</p>

        <h3>Create / Manage Project Permission Forms</h3>
        <div className={css.controlsArea}>

          <div className={css.leftSide}>
            <div>Project:</div>
            <select data-testid="top-project-select" value={currentSelectedProject} onChange={handleProjectSelectChange}>
              <option value="">Select project..</option>
              {projectsData?.map((p: IProject) => <option key={p.id} value={p.id}>{p.name}</option>)}
            </select>
          </div>

          <div className={css.rightSide}>
            <button onClick={() => setShowForm(true)}>Create New Permission Form</button>
          </div>
        </div>

        <table className={css.permissionFormsTable}>
          <thead>
            <tr><th>Name</th><th>URL</th><th></th></tr>
          </thead>
          <tbody>
            {getFilteredForms()?.map((permissionForm: IPermissionForm) => (
              <PermissionFormRow key={permissionForm.id} permissionForm={permissionForm} />
            ))}
          </tbody>
        </table>
      </div>

      {showForm &&
        <CreateNewPermissionForm
          currentSelectedProject={currentSelectedProject}
          onFormCancel={() => setShowForm(false)}
          onFormSave={handleFormSave}
          projects={projectsData}
        />
      }
    </div>
  );
}
