import React, { useState } from "react";
import { IProject, IPermissionForm, CurrentSelectedProject } from "./permission-form-types";

import css from "./style.scss";

interface CreateNewPermissionFormProps {
  currentSelectedProject: CurrentSelectedProject;
  projects: IProject[];
  onFormCancel: () => void;
  onFormSave: (newForm: IPermissionForm) => void;
}

export const CreateNewPermissionForm = ({ projects, currentSelectedProject, onFormSave, onFormCancel }: CreateNewPermissionFormProps) => {
  const authToken = document.querySelector("meta[name=\"csrf-token\"]")?.getAttribute("content");
  const currentSelectedProjectValue = currentSelectedProject ? Number(currentSelectedProject): "";
  const [formData, setFormData] = useState({ name: "", project_id: currentSelectedProjectValue, url: "" });
  const [selectValue, setSelectValue] = useState(Number(currentSelectedProject));
  const handleFormInputChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    setFormData({ ...formData, [e.target.name]: e.target.value });
  };

  const handleFormProjectSelectChange = (e: React.ChangeEvent<HTMLSelectElement>) => {
    setSelectValue(Number(e.target.value));
    setFormData({ ...formData, [e.target.name]: Number(e.target.value) });
  };

  const createNewPermissionForm = async () => {
    if (!authToken) return;
    try {
      const response = await fetch(Portal.API_V1.PERMISSION_FORMS, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": authToken
        },
        body: JSON.stringify({ permission_form: { ...formData } })
      });
      const data = await response.json();
      if (!response.ok) throw new Error(`HTTP error: ${response.status}`);
      if (data.id){
        onFormSave(data);
      }
      setFormData({ name: "", project_id: "", url: ""});
    }
    catch (e) {
      console.error(`POST ${Portal.API_V1.PERMISSION_FORMS} failed.`, e);
    }
  };

  return (
    <div className={css.newForm}>
      <div className={css.formTop}>
        {formData.name.length > 0 ? "Edit: " + formData.name : "New form"}
      </div>

      <div className={css.formRow}>
        <label>Name:</label>
        <div><input type="text" name="name" onChange={handleFormInputChange} autoComplete="off" /></div>
      </div>

      <div className={css.formRow}>
        <label>Project:</label>
        <select value={selectValue} name="project_id" onChange={handleFormProjectSelectChange}>
          <option value="">Select a project...</option>
          {projects?.map((p: IProject) => <option key={p.id} value={p.id}>{p.name}</option>)}
        </select>
      </div>

      <div className={css.formRow}>
        <label>URL:</label>
        <input type="text" name="url" onChange={handleFormInputChange} autoComplete="off"/>
      </div>

      <div className={css.formButtonArea}>
        <button className={css.cancelButton} onClick={onFormCancel}>
          Cancel
        </button>
        <button disabled={!formData.name || !formData.project_id} onClick={createNewPermissionForm}>
          Save
        </button>
      </div>
    </div>
  );
};
