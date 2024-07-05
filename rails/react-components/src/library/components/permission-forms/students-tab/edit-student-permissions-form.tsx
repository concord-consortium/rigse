import React, { useEffect, useState } from "react";
import { IPermissionForm, IStudent } from "./types";

import css from "./edit-student-permissions-form.scss";

interface CreateEditPermissionFormProps {
  student: IStudent;
  permissionForms: IPermissionForm[];
  onFormCancel: () => void;
  onFormSave: ({ studentId, idsToAdd, idsToRemove }: { studentId: number; idsToAdd: number[]; idsToRemove: number[] }) => void;
}

export const EditStudentPermissionsForm = ({ student, permissionForms, onFormCancel, onFormSave }: CreateEditPermissionFormProps) => {
  const [localPermissions, setLocalPermissions] = useState(student.permission_forms || []);

  useEffect(() => {
    setLocalPermissions(student.permission_forms);
  }, [student.permission_forms]);

  // whenever a permission checkbox changes we figure out if it represents an add or a remove
  // we update the form state and the idsToAdd and idsToRemove arrays accordingly
  const handlePermissionChange = (changedPermissionId: number) => {
    const shouldAddPermission = !localPermissions.some(lp => lp.id === changedPermissionId);
    const shouldRemovePermission = localPermissions.some(lp => lp.id === changedPermissionId);

    let newPermissions: IPermissionForm[] = [];

    if (shouldAddPermission) {
      const permissionToAdd = permissionForms.find(pf => pf.id === changedPermissionId);
      if (permissionToAdd) {
        newPermissions = [...localPermissions, permissionToAdd];
      }
    }

    if (shouldRemovePermission) {
      newPermissions = localPermissions.filter(lp => lp.id !== changedPermissionId);
    }
    setLocalPermissions(newPermissions);
  };

  const handleFormSave = async () => {
    const idsToAdd = localPermissions.filter(lp => !student.permission_forms.some(pf => pf.id === lp.id)).map(lp => lp.id);
    const idsToRemove = student.permission_forms.filter(pf => !localPermissions.some(lp => lp.id === pf.id)).map(pf => pf.id);

    onFormSave({ studentId: student.id, idsToAdd, idsToRemove });
  };

  // Check if there are any changes to the permissions so we know whether to enable the save button
  const savedIds = student.permission_forms.map(pf => pf.id).sort();
  const newIds = localPermissions.map(lp => lp.id).sort();
  const hasChanges = savedIds.length !== newIds.length || savedIds.some((id, i) => id !== newIds[i]);
  const sortedPermissions = permissionForms.sort((a, b) => a.name.localeCompare(b.name));

  return (
    <div className={css.editStudentPermissionsForm}>
      <div className={css.formTop}>
        <div className={css.studentName}>
          { `EDIT Permission Forms for: ${student.name}` }
        </div>
        <div className={css.closeButton}>
          <button onClick={onFormCancel}>
            <i className="icon-close" />
          </button>
        </div>
      </div>
      <div className={css.scrollableWrapper}>
        { sortedPermissions.map((p, i) => {
          const isChecked = localPermissions.some(lp => lp.id === p.id);

          return (
            <div key={i} className={css.formRow}>
              <input
                type="checkbox"
                checked={isChecked}
                onChange={() => handlePermissionChange(p.id)}
              />
              { p.name }
            </div>
          );
        }) }
      </div>

      <div className={css.formButtonArea}>
        <button className={css.cancelButton} onClick={onFormCancel}>
          Cancel
        </button>
        <button disabled={!hasChanges} className={css.saveChangesButton} onClick={handleFormSave}>
          Save Changes
        </button>
      </div>
    </div>
  );
};
