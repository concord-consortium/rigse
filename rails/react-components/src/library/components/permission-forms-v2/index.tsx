import React, { useState, useEffect } from "react";
import PermissionFormRow from "./permission-form-row";
import css from "./style.scss"
import { CreateNewPermissionForm } from "./create-new-permission-form";

const emptyFormData = { name: "", project_id: "", url: ""};

export default function PermissionFormsV2() {
  const permissionFormsUrl = Portal.API_V1.PERMISSION_FORMS;
  const projectsUrl = Portal.API_V1.PROJECTS;
  const authToken = document.querySelector("meta[name='csrf-token']")?.getAttribute("content");

  const [permissionForms, setPermissionForms] = useState<any>(null);
  const [projects, setProjects] = useState<any>(null);
  const [formData, setFormData] = useState(emptyFormData);
  const [showForm, setShowForm] = useState(false);
  const [currentSelectedProject, setCurrentSelectedProject] = useState("");
  const [visibleForms, setVisibleForms] = useState(permissionForms);

  const handleFormInputChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    setFormData({ ...formData, [e.target.name]: e.target.value });
  };

  const handleFormProjectSelectChange = (e: React.ChangeEvent<HTMLSelectElement>) => {
    setFormData({ ...formData, [e.target.name]: Number(e.target.value) });
  }

  const handleCreateNewFormClick = () => {
    setShowForm(true);
  };

  const handleProjectSelectChange = (e: React.ChangeEvent<HTMLSelectElement>) => {
    setCurrentSelectedProject(e.target.value);
  };

  const handleCancelClick = () => {
    setShowForm(false);
    setFormData(emptyFormData);
  };

  // fetch data
  useEffect(() => {
    const fetchData = async () => {
      try {
        const permissionResponse = await fetch(permissionFormsUrl);
        if (!permissionResponse.ok) throw new Error(`HTTP error: ${permissionResponse.status}`);
        const permissionData = await permissionResponse.json();
        setPermissionForms(permissionData);

        const projectsResponse = await fetch(projectsUrl);
        if (!projectsResponse.ok) throw new Error(`HTTP error: ${projectsResponse.status}`);
        const projectsData = await projectsResponse.json();
        setProjects(projectsData);
      }
      catch (e) {
        console.error(`GET ${permissionFormsUrl} failed.`, e);
      }
    };

    fetchData();
  }, [permissionFormsUrl, projectsUrl]);

  // update visible permissions when project changes
  useEffect(() => {
    const belongsToSelectedProject = (form: any) => form.project_id === Number(currentSelectedProject);
    const formsToDisplay = currentSelectedProject === ""
      ? permissionForms
      : permissionForms?.filter(belongsToSelectedProject);

    setVisibleForms(formsToDisplay);
  }, [permissionForms, currentSelectedProject]);

  const createNewPermissionForm = async () => {
    if (!authToken) return;
    try {
      const response = await fetch(permissionFormsUrl, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": authToken
        },
        body: JSON.stringify({ permission_form: { ...formData } })
      });
      const data = await response.json()
      if (!response.ok) throw new Error(`HTTP error: ${response.status}`);
      if (data.id){
        setPermissionForms([...permissionForms, {
          id: data.id, url: data.url, project_id: data.project_id, name: data.name
        }]);
      }
      setFormData(emptyFormData);
    }
    catch (e) {
      console.error(`POST ${permissionFormsUrl} failed.`, e);
    }
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

      { showForm &&
        <CreateNewPermissionForm
          formData={formData}
          handleFormInputChange={handleFormInputChange}
          handleFormProjectSelectChange={handleFormProjectSelectChange}
          createNewPermissionForm={createNewPermissionForm}
          handleCancelClick={handleCancelClick}
          projects={projects}
        />
      }
    </div>
  );
}
