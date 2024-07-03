import React, { useState } from "react";
import StudentsTab from "./students-tab/students-tab";
import ManageFormsTab from "./manage-forms-tab/manage-forms-tab";
import { LinkButton } from "./common/link-button";

import css from "./index.scss";

type PermissionsTab = "manageFormsTab" | "studentsTab";

export default function PermissionForms() {
  // State for UI
  const [openTab, setOpenTab] = useState<PermissionsTab>("studentsTab");

  return (
    <div className={css.permissionForms}>

      <div className={css.tabArea}>
        <h2>Permission Form Options</h2>
        <div className={css.tabs}>
          <LinkButton active={openTab === "studentsTab"} disabled={openTab === "studentsTab"} onClick={() => setOpenTab("studentsTab")}>
            Manage Student Permissions
          </LinkButton>
          <LinkButton active={openTab === "manageFormsTab"} disabled={openTab === "manageFormsTab"} onClick={() => setOpenTab("manageFormsTab")}>
            Create / Manage Project Permission Forms
          </LinkButton>
        </div>
      </div>

      <h3>{ openTab === "manageFormsTab" ? "Create/ Manage Project Permission Forms" : "Manage Student Permissions" }</h3>

      { openTab === "manageFormsTab" ? <ManageFormsTab /> : <StudentsTab /> }
    </div>
  );
}
