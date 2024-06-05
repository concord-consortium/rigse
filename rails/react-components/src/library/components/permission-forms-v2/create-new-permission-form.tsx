import React from 'react';
import css from './style.scss';

// make a type for the props
type CreateNewPermissionFormProps = {
  formData: any;
  handleFormInputChange: (e: React.ChangeEvent<HTMLInputElement>) => void;
  handleFormProjectSelectChange: (e: React.ChangeEvent<HTMLSelectElement>) => void;
  createNewPermissionForm: () => void;
  handleCancelClick: () => void;
  projects: any;
};

export const CreateNewPermissionForm = ({ formData, handleFormInputChange, handleFormProjectSelectChange, projects, createNewPermissionForm, handleCancelClick }: CreateNewPermissionFormProps) => (
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

    <div className={css.formButtonArea}>
      <button className={css.cancelButton} onClick={handleCancelClick}>
        Cancel
      </button>

      <button disabled={!formData.name || !formData.project_id} onClick={createNewPermissionForm}>
        Save
      </button>
    </div>
  </div>
);
