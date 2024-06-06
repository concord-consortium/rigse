import React, { useState } from 'react';
import css from './style.scss';

type CreateNewPermissionFormProps = {
  currentSelectedProject: any;
  projects: any;
  onFormCancel: () => void;
  onFormSave: (newForm: any) => void;
};

const emptyFormData = { name: "", project_id: "", url: ""};
const permissionsUrl = Portal.API_V1.PERMISSION_FORMS;

export const CreateNewPermissionForm = ({ projects, currentSelectedProject, onFormSave, onFormCancel }: CreateNewPermissionFormProps) => {
  const authToken = document.querySelector("meta[name='csrf-token']")?.getAttribute("content");
  const [formData, setFormData] = useState({ name: "", project_id: currentSelectedProject, url: "" });

  const handleFormInputChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    setFormData({ ...formData, [e.target.name]: e.target.value });
  };

  const handleFormProjectSelectChange = (e: React.ChangeEvent<HTMLSelectElement>) => {
    setFormData({ ...formData, [e.target.name]: Number(e.target.value) });
  }

  const createNewPermissionForm = async () => {
    if (!authToken) return;
    try {
      const response = await fetch(permissionsUrl, {
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
        onFormSave(data);
      }
      setFormData(emptyFormData);
    }
    catch (e) {
      console.error(`POST ${permissionsUrl} failed.`, e);
    }
  };

  return (
    <div className={css.newForm}>
      <h3>Create new Permission form</h3>

      <label>Name:</label>
      <input type="text" name="name" onChange={handleFormInputChange} />

      <label>Project:</label>
      <select name="project_id" onChange={handleFormProjectSelectChange}>
        <option value="">Select a project...</option>
        {projects?.map((project: any) => (
          <option key={project.id} value={project.id}>
            {project.name}
          </option>
        ))}
      </select>

      <label>URL:</label>
      <input type="text" name="url" onChange={handleFormInputChange}/>
      <button
        disabled={!formData.name || !formData.project_id}
        onClick={createNewPermissionForm}
      >
        Save
      </button>
      <button className={css.cancelButton} onClick={onFormCancel}>
        Cancel
      </button>
    </div>
  );
};
