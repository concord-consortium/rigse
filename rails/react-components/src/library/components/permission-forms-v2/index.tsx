import React, { useState, useEffect } from "react";
import PermissionFormRow from "./permission-form-row";
import { useFetch } from "./use-fetch";
import css from "./style.scss"
import { CreateNewPermissionForm } from "./create-new-permission-form";

export default function PermissionFormsV2() {
  const permissionsUrl = Portal.API_V1.PERMISSION_FORMS;
  const projectsUrl = Portal.API_V1.PROJECTS;

  const [permissionForms, setPermissionForms] = useState<any>(null);
  const { data: permissionsData, isLoading: permissionsLoading, error: permissionsError } = useFetch(permissionsUrl, null);

  const [projects, setProjects] = useState<any>(null);
  const { data: projectsData, isLoading: projectsLoading, error: projectsError } = useFetch(projectsUrl, null);

  const [showForm, setShowForm] = useState(false);
  const [currentSelectedProject, setCurrentSelectedProject] = useState("");
  const [visibleForms, setVisibleForms] = useState(permissionForms);

  useEffect(() => {
    setPermissionForms(permissionsData);
  }, [permissionsData]);

  useEffect(() => {
    setProjects(projectsData);
  }, [projectsData]);

  const handleCreateNewFormClick = () => {
    setShowForm(true);
  };

  const handleProjectSelectChange = (e: React.ChangeEvent<HTMLSelectElement>) => {
    setCurrentSelectedProject(e.target.value);
  };

  const handleCancelClick = () => {
    setShowForm(false);
  };

  const updatePermissionForms = (newForm: any) => {
    setPermissionForms([...permissionForms, newForm]);
  };

  // update visible permissions list when project changes
  useEffect(() => {
    const belongsToSelectedProject = (form: any) => form.project_id === Number(currentSelectedProject);
    const formsToDisplay = currentSelectedProject === ""
      ? permissionForms
      : permissionForms?.filter(belongsToSelectedProject);

    setVisibleForms(formsToDisplay);
  }, [permissionForms, currentSelectedProject]);

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
              {projects && projects.map((project: any) => (
                <option key={project.id} value={project.id}>
                  {project.name}
                </option>
              ))}
            </select>
          </div>
          <div className={css.rightSide}>
            <button onClick={handleCreateNewFormClick}>Create New Permission Form</button>
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
          handleCancelClick={handleCancelClick}
          updatePermissionForms={updatePermissionForms}
          projects={projects}
        />
      }
    </div>
  );
}
