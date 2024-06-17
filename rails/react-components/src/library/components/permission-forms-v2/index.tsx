import React, { useState } from "react";
import { PermissionsTab } from "./permission-form-types";
import StudentsTab from "./students-tab";
import ManageFormsTab from "./manage-forms-tab";

import css from "./index.scss";

export default function PermissionFormsV2() {
  // State for UI
  const [openTab, setOpenTab] = useState<PermissionsTab>("studentsTab");

  return (
    <div className={css.permissionForms}>

      <div className={css.tabArea}>
        <h2>Permission Form Options</h2>
        <div className={css.tabs}>
          <a
            className={openTab === "studentsTab" ? css.activeTab : ""}
            onClick={() => setOpenTab("studentsTab")}
          >
            Manage Student Permissions
          </a>
          <a
            className={openTab === "manageFormsTab" ? css.activeTab : ""}
            onClick={() => setOpenTab("manageFormsTab")}
          >
            Create / Manage Project Permission Forms
          </a>
        </div>
      </div>

      <h3>{ openTab === "manageFormsTab" ? "Create/ Manage Project Permission Forms" : "Manage Student Permissions" }</h3>

      { openTab === "manageFormsTab" ? <ManageFormsTab /> : <StudentsTab /> }
    </div>
  );
}
