import React, { useState, useEffect } from "react";
import PermissionFormRow from "./permission-form-row";
import css from "./style.scss"
interface IProps {
  dataUrl: string;
}

const emptyFormData = { name: "", project_id: "", url: ""};

export default function PermissionFormsV2({dataUrl}: IProps) {
  const authToken = document.querySelector("meta[name='csrf-token']")?.getAttribute("content");
  const [permissionForms, setPermissionForms] = useState<any>(null);
  const [formData, setFormData] = useState(emptyFormData);
  const [showForm, setShowForm] = useState(false);

  const handleFormChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    setFormData({ ...formData, [e.target.name]: e.target.value });
  };

  const handleCreateNewFormClick = () => {
    setShowForm(true);
  }

  useEffect(() => {
    const fetchData = async () => {
      try {
        const response = await fetch(dataUrl);
        if (!response.ok) throw new Error(`HTTP error: ${response.status}`);

        const data = await response.json();
        setPermissionForms(data);
      }
      catch (e) {
        console.error(`GET ${dataUrl} failed.`, e);
      }
    };

    fetchData();
  }, [dataUrl]);

  const createNewPermissionForm = async () => {
    if (!authToken) return;
    try {
      const response = await fetch(dataUrl, {
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
        setPermissionForms([...permissionForms, {id: data.id, url: data.url, name: data.name}]);
      }
      setFormData(emptyFormData);
    }
    catch (e) {
      console.error(`POST ${dataUrl} failed.`, e);
    }
  };

  return (
    <div className={css.permissionForms}>
      <div className={css.tableAndControls}>
        <h2>Permission Form Options</h2>
        <p>Breadcrumbs...</p>

        <h3>Create / Manage Project Permission Forms</h3>
        <div className={css.controlsArea}>
          <div className={css.leftSide}>
            <div>Project:</div>
            <select>
              <option value="one">one</option>
              <option value="two">two</option>
              <option value="archived">three</option>
            </select>
          </div>
          <div className={css.rightSide}>
            <button onClick={handleCreateNewFormClick}>Create New Permission Form</button>
          </div>
        </div>
        <table className={css.permissionFormsTable}>
          <thead>
            <tr>
              <th>Name</th>
              <th>URL</th>
              <th></th>
            </tr>
          </thead>
          <tbody>
            {permissionForms?.map((permissionForm: any) => (
              <PermissionFormRow key={permissionForm.id} permissionForm={permissionForm} />
            ))}
          </tbody>
        </table>
      </div>

      { showForm &&
        <div className={css.newForm}>
          <h3>Create new Permission form</h3>

          <label>Name:</label>
          <input type="text" name="name" onChange={handleFormChange} />

          <label>Project:</label>
          <input type="text" name="project" onChange={handleFormChange} />

          <label>URL:</label>
          <input type="text" name="url" onChange={handleFormChange} />

          <button onClick={createNewPermissionForm}>Create</button>
        </div>
      }
    </div>
  );
}
