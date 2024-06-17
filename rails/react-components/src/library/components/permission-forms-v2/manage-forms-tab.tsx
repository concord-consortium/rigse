import React, { useState } from "react";
import { useFetch } from "../../hooks/use-fetch";
import { CreateEditPermissionForm } from "./create-edit-permission-form";
import { IPermissionForm, IPermissionFormFormData, IProject, CurrentSelectedProject } from "./permission-form-types";
import PermissionFormRow from "./permission-form-row";
import { ProjectSelect } from "./project-select";
import ModalDialog from "../shared/modal-dialog";

import css from "./manage-forms-tab.scss";

const getAuthToken = () => {
  const authToken = document.querySelector("meta[name=\"csrf-token\"]")?.getAttribute("content");
  if (!authToken) {
    throw new Error("CSRF token not found.");
  }
  return authToken;
};

const request = async ({ url, method, body }: { url: string, method: string, body?: string }) => {
  try {
    const response = await fetch(url, {
      method,
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": getAuthToken()
      },
      body
    });
    const data = await response.json();
    if (!response.ok) {
      throw new Error(`HTTP error: ${response.status}`);
    }
    return data;
  } catch (e) {
    console.error(`${method} ${url} failed.`, e);
  }
  return null;
};

const createNewPermissionForm = async (formData: IPermissionFormFormData): Promise<IPermissionForm | null> =>
  request({
    url: Portal.API_V1.PERMISSION_FORMS,
    method: "POST",
    body: JSON.stringify({ permission_form: { ...formData } })
  });

const editPermissionForm = async (formData: IPermissionFormFormData): Promise<IPermissionForm | null> =>
  request({
    url: `${Portal.API_V1.PERMISSION_FORMS}/${formData.id}`,
    method: "PUT",
    body: JSON.stringify({ permission_form: { ...formData } })
  });

const deletePermissionForm = async (permissionFormId: string) =>
  request({
    url: `${Portal.API_V1.PERMISSION_FORMS}/${permissionFormId}`,
    method: "DELETE"
  });

const getFilteredForms = (forms: IPermissionForm[], projectId: string | number) =>
  projectId === "" ? forms : forms.filter((form: IPermissionForm) => form.project_id === Number(projectId));

const sortByName = (a: { name: string }, b: { name: string }) => a.name.localeCompare(b.name);

// Sort forms by is_archived first and then by name
const sortForms = (forms: IPermissionForm[]) => forms.sort((a, b) => {
  if (a.is_archived === b.is_archived) {
    return sortByName(a, b);
  }
  return a.is_archived ? 1 : -1;
});

export default function ManageFormsTab() {
  // Fetch projects and permission forms (with refetch function) on initial load
  const { data: permissionsData, refetch: refetchPermissions } = useFetch<IPermissionForm[]>(Portal.API_V1.PERMISSION_FORMS, []);
  const { data: projectsData } = useFetch<IProject[]>(Portal.API_V1.PROJECTS_WITH_PERMISSIONS, []);

  // State for UI
  const [showCreateNewFormModal, setShowCreateNewFormModal] = useState(false);
  const [editForm, setEditForm] = useState<IPermissionForm | false>(false);
  const [currentSelectedProject, setCurrentSelectedProject] = useState<number | "">("");

  const handleProjectSelectChange = (e: React.ChangeEvent<HTMLSelectElement>) => {
    setCurrentSelectedProject(e.target.value as CurrentSelectedProject);
  };

  const handleCreateFormClick = () => {
    setShowCreateNewFormModal(true);
  };

  const handleCreateFormSave = async (newFormData: IPermissionFormFormData) => {
    const newForm = await createNewPermissionForm(newFormData);
    if (newForm) {
      setCurrentSelectedProject(newForm.project_id as CurrentSelectedProject);
      setShowCreateNewFormModal(false);
      refetchPermissions();
    }
  };

  const handleEditButtonClick = (permissionForm: IPermissionForm) => {
    setEditForm(permissionForm);
  };

  const handleEdit = async (permissionForm: IPermissionForm) => {
    const updatedForm = await editPermissionForm(permissionForm);
    if (updatedForm) {
      refetchPermissions();
    }
  };

  const handleEditModalSave = async (newFormData: IPermissionFormFormData) => {
    const updatedForm = await editPermissionForm(newFormData);
    if (updatedForm) {
      setCurrentSelectedProject(updatedForm.project_id as CurrentSelectedProject);
      setEditForm(false);
      refetchPermissions();
    }
  };

  const handleDeleteClick = async (permissionFormId: string) => {
    await deletePermissionForm(permissionFormId);
    refetchPermissions();
  };

  const processedForms = sortForms(getFilteredForms(permissionsData, currentSelectedProject));

  return (
    <div className={css.manageFormsTabContent}>
      <div className={css.controlsArea}>
        <div className={css.leftSide}>
          <ProjectSelect projects={projectsData} value={currentSelectedProject} onChange={handleProjectSelectChange} />
        </div>
        <div className={css.rightSide}>
          <button onClick={handleCreateFormClick}>Create New Permission Form</button>
        </div>
      </div>

      <table className={css.permissionFormsTable}>
        <thead>
          <tr><th>Name</th><th>URL</th><th></th></tr>
        </thead>
        <tbody>
          {
            processedForms.map((permissionForm: IPermissionForm) => (
              <PermissionFormRow
                key={permissionForm.id}
                permissionForm={permissionForm}
                onEditModalToggle={handleEditButtonClick}
                onEdit={handleEdit}
                onDelete={handleDeleteClick}
              />
            ))
          }
        </tbody>
      </table>
      {
        showCreateNewFormModal &&
        <ModalDialog styles={{ padding: "0px" }}>
          <CreateEditPermissionForm
            currentSelectedProject={currentSelectedProject}
            onFormCancel={() => setShowCreateNewFormModal(false)}
            onFormSave={handleCreateFormSave}
            projects={projectsData}
          />
        </ModalDialog>
      }
      {
        editForm &&
        <ModalDialog styles={{ padding: "0px" }}>
          <CreateEditPermissionForm
            existingFormData={editForm}
            onFormCancel={() => setEditForm(false)}
            onFormSave={handleEditModalSave}
            projects={projectsData}
          />
        </ModalDialog>
      }
    </div>
  );
}
