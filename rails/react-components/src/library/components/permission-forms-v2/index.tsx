import React, { useState, useEffect } from "react";
import PermissionFormRow from "./permission-form-row";
import { useFetch } from "./use-fetch";
import css from "./style.scss"
import { CreateNewPermissionForm } from "./create-new-permission-form";

export default function PermissionFormsV2() {
  // Fetch permission forms and projects on load
  const { data: permissionsData } = useFetch(Portal.API_V1.PERMISSION_FORMS, null);
  const { data: projectsData } = useFetch(Portal.API_V1.PROJECTS, null);

  // State for permission forms and projects
  const [permissionForms, setPermissionForms] = useState<any>(null);
  const [projects, setProjects] = useState<any>(null);

  // State for UI
  const [showForm, setShowForm] = useState(false);
  const [currentSelectedProject, setCurrentSelectedProject] = useState<any>(""); // TODO this can be too many things
  const [visibleForms, setVisibleForms] = useState(permissionForms);

  // Update state when data is fetched
  useEffect(() => setPermissionForms(permissionsData), [permissionsData]);
  useEffect(() => setProjects(projectsData), [projectsData]);

  // update visible permissions list when project changes
  useEffect(() => {
    const belongsToSelectedProject = (form: any) => form.project_id === Number(currentSelectedProject);
    const formsToDisplay = currentSelectedProject === ""
    ? permissionForms
    : permissionForms?.filter(belongsToSelectedProject);

    setVisibleForms(formsToDisplay);
  }, [permissionForms, currentSelectedProject]);

  const handleProjectSelectChange = (e: React.ChangeEvent<HTMLSelectElement>) => {
    console.log("| PARENT changing currentSelectedProject to: ", e.target.value);
    setCurrentSelectedProject(e.target.value);
  };

  const updatePermissionForms = (newForm: any) => {
    setPermissionForms([...permissionForms, newForm]);
    setCurrentSelectedProject(newForm.project_id);
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
            <select value={currentSelectedProject} onChange={handleProjectSelectChange}>
              <option value="">Select project..</option>
              {projects && projects.map((p: any) => <option key={p.id} value={p.id}>{p.name}</option>)}
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
            {visibleForms?.map((permissionForm: any) => (
              <PermissionFormRow key={permissionForm.id} permissionForm={permissionForm} />
            ))}
          </tbody>
        </table>
      </div>

      {showForm &&
        <CreateNewPermissionForm
          currentSelectedProject={currentSelectedProject}
          onFormCancel={() => setShowForm(false)}
          onFormSave={updatePermissionForms}
          projects={projects}
        />
      }
    </div>
  );
}
