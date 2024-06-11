import React, { useState } from "react";
import { useFetch } from "../../hooks/use-fetch";
import { CreateNewPermissionForm } from "./create-new-permission-form";
import { IPermissionForm, IProject, CurrentSelectedProject, PermissionsTab } from "./permission-form-types";
import PermissionFormRow from "./permission-form-row";
import ModalDialog from "../shared/modal-dialog";

import css from "./style.scss";

export default function PermissionFormsV2() {
  // Fetch projects and permission forms (with refetch function) on initial load
  const { data: permissionsData, refetch: refetchPermissions } = useFetch<IPermissionForm[]>(Portal.API_V1.PERMISSION_FORMS, []);
  const { data: projectsData } = useFetch<IProject[]>(Portal.API_V1.PROJECTS, []);

  // State for UI
  const [openTab, setOpenTab] = useState<PermissionsTab>("projectsTab");
  const [showCreateNewFormModal, setShowCreateNewFormModal] = useState(false);
  const [currentSelectedProject, setCurrentSelectedProject] = useState<number | "">("");

  const handleProjectSelectChange = (e: React.ChangeEvent<HTMLSelectElement>) => {
    setCurrentSelectedProject(e.target.value as CurrentSelectedProject);
  };

  const handleFormSave = (newForm: IPermissionForm) => {
    setCurrentSelectedProject(newForm.project_id as CurrentSelectedProject);
    setShowCreateNewFormModal(false);
    refetchPermissions();
  };

  const getFilteredForms = () => {
    const belongsToSelectedProject = (form: IPermissionForm) => form.project_id === Number(currentSelectedProject);
    return currentSelectedProject === ""
      ? permissionsData
      : permissionsData?.filter(belongsToSelectedProject);
  };

  return (
    <div className={css.permissionForms}>

      <div className={css.tabArea}>
        <h2>Permission Form Options</h2>
        <div className={css.tabs}>
          <button
            className={openTab === "projectsTab" ? css.activeTab : ""}
            onClick={() => setOpenTab("projectsTab")}
          >
            Create / Manage Project Permission Forms
          </button>
          <button
            className={openTab === "studentsTab" ? css.activeTab : ""}
            onClick={() => setOpenTab("studentsTab")}
          >
            Manage Student Permissions
          </button>
        </div>
      </div>

      { openTab === "projectsTab" &&
        <div className={css.projectPermissionsTabContent}>
          <h3>Create/Manage Project Permission Forms</h3>
          <div className={css.controlsArea}>
            <div className={css.leftSide}>
              <div>Project:</div>
              <select data-testid="top-project-select" value={currentSelectedProject} onChange={handleProjectSelectChange}>
                <option value="">Select project..</option>
                { projectsData?.map((p: IProject) => <option key={p.id} value={p.id}>{ p.name }</option>) }
              </select>
            </div>
            <div className={css.rightSide}>
              <button onClick={() => setShowCreateNewFormModal(true)}>Create New Permission Form</button>
            </div>
          </div>

          <table className={css.permissionFormsTable}>
            <thead>
              <tr><th>Name</th><th>URL</th><th></th></tr>
            </thead>
            <tbody>
              { getFilteredForms()?.map((permissionForm: IPermissionForm) => (
                <PermissionFormRow key={permissionForm.id} permissionForm={permissionForm} />
              )) }
            </tbody>
          </table>
        </div>
      }

      { showCreateNewFormModal &&
        <ModalDialog styles={{ padding: "0px" }}>
          <CreateNewPermissionForm
            currentSelectedProject={currentSelectedProject}
            onFormCancel={() => setShowCreateNewFormModal(false)}
            onFormSave={handleFormSave}
            projects={projectsData}
          />
        </ModalDialog>
      }
    </div>
  );
}
