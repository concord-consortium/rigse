import React, { useState } from "react";
import { clsx } from "clsx";
import { useFetch } from "../../../hooks/use-fetch";
import { CreateEditPermissionForm } from "./create-edit-permission-form";
import { IPermissionForm, IPermissionFormFormData, IProject, CurrentSelectedProject } from "./types";
import { ProjectSelect } from "../common/project-select";
import { request } from "../../../helpers/api/request";
import { filteredByProject, sortedByArchiveAndName } from "../common/permission-utils";
import PermissionFormRow from "./permission-form-row";
import ModalDialog from "../../shared/modal-dialog";

import css from "./manage-forms-tab.scss";

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

const deletePermissionForm = async (permissionFormId: number) =>
  request({
    url: `${Portal.API_V1.PERMISSION_FORMS}/${permissionFormId}`,
    method: "DELETE"
  });

export default function ManageFormsTab() {
  // Fetch projects and permission forms (with refetch function) on initial load
  const { data: permissionsData, refetch: refetchPermissions } = useFetch<IPermissionForm[]>(Portal.API_V1.PERMISSION_FORMS, []);
  const { data: projectsData } = useFetch<IProject[]>(Portal.API_V1.PERMISSION_FORMS_PROJECTS, []);

  // State for UI
  const [showCreateNewFormModal, setShowCreateNewFormModal] = useState(false);
  const [editForm, setEditForm] = useState<IPermissionForm | false>(false);
  const [currentSelectedProject, setCurrentSelectedProject] = useState<CurrentSelectedProject>(null);

  const handleProjectSelectChange = (e: React.ChangeEvent<HTMLSelectElement>) => {
    setCurrentSelectedProject(e.target.value === "" ? null : Number(e.target.value));
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

  const handleDeleteClick = async (permissionFormId: number) => {
    await deletePermissionForm(permissionFormId);
    refetchPermissions();
  };

  const processedForms = sortedByArchiveAndName(filteredByProject(permissionsData, currentSelectedProject));
  const cantDeleteAnyForm = processedForms.every((form: IPermissionForm) => form.can_delete === false);

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
          <tr>
            <th>Name</th><th>URL</th>
            <th className={css.editColumn} />
            <th className={css.archiveColumn} />
            <th className={clsx(css.deleteColumn, { [css.hiddenColumn]: cantDeleteAnyForm })} />
          </tr>
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
        <ModalDialog borderColor="orange">
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
        <ModalDialog borderColor="orange">
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
