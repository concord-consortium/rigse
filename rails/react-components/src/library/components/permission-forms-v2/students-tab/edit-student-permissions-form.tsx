import React from "react";
import { IPermissionForm, IStudent } from "./types";

import css from "./edit-student-permissions-form.scss";

interface CreateEditPermissionFormProps {
  existingFormData?: any;
  student: IStudent;
  permissionForms: IPermissionForm[];
  onFormCancel: () => void;
  onFormSave: (newForm: any) => void;
}

export const EditStudentPermissionsForm = ({ student, existingFormData, permissionForms, onFormSave, onFormCancel }: CreateEditPermissionFormProps) => {

  const disabled = false;
  console.log("| student: ", student);
  return (
    <div className={css.editStudentPerimissionsForm}>
      <div className={css.formTop}>
        { `EDIT: ${student.name}` }
      </div>

      {permissionForms.map((p, i) => {
        console.log("| one of all existing p forms: ", p.id, p.name);
        const isChecked = student.permission_forms.some(pf => pf.id === p.id);

        return (
          <div key={i} className={css.formRow}>
            <input type="checkbox" checked={isChecked} /> {p.name}
          </div>
        );
      })}

      <div className={css.formButtonArea}>
        <button className={css.cancelButton} onClick={onFormCancel}>
          Cancel
        </button>
        <button disabled={disabled} className={css.saveChangesButton} onClick={onFormSave}>
          { existingFormData ? "Save Changes" : "Save" }
        </button>
      </div>
    </div>
  );
};
