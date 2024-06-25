import React from "react";
import { IStudent } from "./types";

import css from "./edit-student-permissions-form.scss";

interface CreateEditPermissionFormProps {
  existingFormData?: any;
  student: IStudent;
  onFormCancel: () => void;
  onFormSave: (newForm: any) => void;
}

export const EditStudentPermissionsForm = ({ student, existingFormData, onFormSave, onFormCancel }: CreateEditPermissionFormProps) => {

  const disabled = false;

  return (
    <div className={css.editStudentPerimissionsForm}>
      <div className={css.formTop}>
        { `EDIT: ${student.name}` }
      </div>

      <div className={css.formRow}>
        form row
      </div>

      <div className={css.formButtonArea}>
        <button className={css.cancelButton} onClick={onFormCancel}>
          Cancel
        </button>
        <button disabled={disabled} onClick={onFormSave}>
          { existingFormData ? "Save Changes" : "Save" }
        </button>
      </div>
    </div>
  );
};
