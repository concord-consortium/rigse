import React, { useState } from "react";
import { IProject, IPermissionFormFormData, CurrentSelectedProject, IPermissionForm } from "./permission-form-types";

import css from "./style.scss";

interface CreateEditPermissionFormProps {
  existingFormData?: IPermissionForm;
  currentSelectedProject?: CurrentSelectedProject;
  projects: IProject[];
  onFormCancel: () => void;
  onFormSave: (newForm: IPermissionFormFormData) => void;
}

export const CreateEditPermissionForm = ({ projects, currentSelectedProject, existingFormData, onFormSave, onFormCancel }: CreateEditPermissionFormProps) => {
  const [formData, setFormData] = useState<IPermissionFormFormData>({
    id: existingFormData?.id || undefined,
    name: existingFormData?.name || "",
    project_id: existingFormData?.project_id || (currentSelectedProject ? Number(currentSelectedProject) : ""),
    url: existingFormData?.url || ""
  });

  const handleFormInputChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    setFormData(prevFormData => ({ ...prevFormData, [e.target.name]: e.target.value }));
  };

  const handleFormProjectSelectChange = (e: React.ChangeEvent<HTMLSelectElement>) => {
    setFormData(prevFormData => ({ ...prevFormData, [e.target.name]: Number(e.target.value) }));
  };

  const handleFormSave = () => {
    onFormSave(formData);
  };

  return (
    <div className={css.newPermissionForm}>
      <div className={css.formTop}>
        { existingFormData ? `EDIT: ${existingFormData.name}` : "Create New Permission Form" }
      </div>
      <div className={css.formRow}>
        <label>Name:</label>
        <div><input type="text" name="name" value={formData.name} onChange={handleFormInputChange} autoComplete="off" /></div>
      </div>

      <div className={css.formRow}>
        <label>Project:</label>
        <select value={formData.project_id} name="project_id" onChange={handleFormProjectSelectChange}>
          <option value="">Select a project...</option>
          { projects?.map((p: IProject) => <option key={p.id} value={p.id}>{ p.name }</option>) }
        </select>
      </div>

      <div className={css.formRow}>
        <label>URL:</label>
        <input type="text" name="url" value={formData.url} onChange={handleFormInputChange} autoComplete="off"/>
      </div>

      <div className={css.formButtonArea}>
        <button className={css.cancelButton} onClick={onFormCancel}>
          Cancel
        </button>
        <button disabled={!formData.name || !formData.project_id} onClick={handleFormSave}>
          Save
        </button>
      </div>
    </div>
  );
};
