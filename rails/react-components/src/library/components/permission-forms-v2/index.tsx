import React, { useState, useEffect } from "react";

interface IProps {
  dataUrl: string;
}

const emptyFormData = { name: "", project_id: "", url: ""};

export default function PermissionFormsV2({dataUrl}: IProps) {
  const authToken = document.querySelector("meta[name='csrf-token']")?.getAttribute("content");
  const [permissionForms, setPermissionForms] = useState<any>(null);
  const [formData, setFormData] = useState(emptyFormData);

  const handleFormChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    setFormData({ ...formData, [e.target.name]: e.target.value });
  };

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
      // QUESTION: it seems like the default beahvior, even though I am not
      // submitting a form is to reload the page.  That is fine for now, but
      // do we want more of a single page app kind of beahvior?
      // E.g.an optimistic update if the `data` comes back correctly below?
      //const data = await response.json()
      if (!response.ok) throw new Error(`HTTP error: ${response.status}`);
      setFormData(emptyFormData);
    }
    catch (e) {
      console.error(`POST ${dataUrl} failed.`, e);
    }
  };

  return (
    <div>
      <div className="permission-forms-list">
        <h2>Permission Forms</h2>
        { permissionForms?.map((permissionForm: any) => (
          <p key={permissionForm.id}>{ permissionForm.id }: { permissionForm.name }</p>
        )) }
      </div>

      <form className="permission-form-form">
        <h3>Create new Permission form</h3>

        <label>Name:</label>
        <input type="text" name="name" onChange={handleFormChange} />

        <label>Project:</label>
        <input type="text" name="project" onChange={handleFormChange} />

        <label>URL:</label>
        <input type="text" name="url" onChange={handleFormChange} />

        <button onClick={createNewPermissionForm}>Create</button>
      </form>
    </div>
  );
}
