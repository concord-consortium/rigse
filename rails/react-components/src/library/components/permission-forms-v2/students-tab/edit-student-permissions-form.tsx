import React, {useEffect, useState} from "react";
import { IPermissionForm, IStudent } from "./types";
import { bulkUpdatePermissionForms } from "./students-table";

import css from "./edit-student-permissions-form.scss";

interface CreateEditPermissionFormProps {
  student: IStudent;
  permissionForms: IPermissionForm[];
  onFormCancel: () => void;
  onFormSave: () => void;
  classId: string;
}

export const EditStudentPermissionsForm = ({ student, permissionForms, onFormCancel, onFormSave, classId }: CreateEditPermissionFormProps) => {
  const [localPermissions, setLocalPermissions] = useState(student.permission_forms || {});
  const [idsToRemove, setIdsToRemove] = useState<string[]>([]);
  const [idsToAdd, setIdsToAdd] = useState<string[]>([]);

  useEffect(() => setLocalPermissions(student.permission_forms), []);

  // whenever a permission checkbox changes we figure out if it represents an add or a remove
  // we update the form state and the idsToAdd and idsToRemove arrays accordingly
  const handlePermissionChange = (changedPermissionId: string) => {
    const shouldAddPermission = !localPermissions.some(lp => lp.id === changedPermissionId);
    const shouldRemovePermission = localPermissions.some(lp => lp.id === changedPermissionId);

    let newPermissions: IPermissionForm[] = [];

    if (shouldAddPermission) {
      const permissionToAdd = permissionForms.find(pf => pf.id === changedPermissionId);
      if (permissionToAdd) {
        newPermissions = [...localPermissions, permissionToAdd];
        setIdsToAdd([...idsToAdd, changedPermissionId]);
      }
    }

    if (shouldRemovePermission) {
      newPermissions = localPermissions.filter(lp => lp.id !== changedPermissionId);
      setIdsToRemove([...idsToRemove, changedPermissionId]);
    }

    const definedPermissions = newPermissions.filter((p): p is IPermissionForm => p !== undefined);
    setLocalPermissions(definedPermissions);
  };

  const handleFormSave = async () => {
    const response = await bulkUpdatePermissionForms({
      classId,
      selectedStudentIds: [student.id.toString()],
      addFormIds: idsToAdd,
      removeFormIds: idsToRemove
    });

    if (response) {
      setIdsToAdd([]);
      setIdsToRemove([]);
      onFormSave();
    } else {
      alert("Failed to update permission forms");
    }
  };

  // Check if there are any changes to the permissions so we know whether to enable the save button
  const savedIds = student.permission_forms.map(pf => pf.id).sort();
  const newIds = localPermissions.map(lp => lp.id).sort();
  const hasChanges = savedIds.length !== newIds.length || savedIds.some((id, i) => id !== newIds[i]);

  return (
    <div className={css.editStudentPerimissionsForm}>
      <div className={css.formTop}>
        { `EDIT: ${student.name}` }
      </div>

      {permissionForms.map((p, i) => {
        const isChecked = localPermissions.some(lp => lp.id === p.id);

        return (
          <div key={i} className={css.formRow}>
            <input
              type="checkbox"
              checked={isChecked}
              onChange={() => handlePermissionChange(p.id)}
            />
            {p.name}
          </div>
        );
      })}

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
