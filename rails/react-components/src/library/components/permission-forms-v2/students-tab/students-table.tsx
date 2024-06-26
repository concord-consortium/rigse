import React, { useState } from "react";
import Select from "react-select";
import { useFetch } from "../../../hooks/use-fetch";
import { request } from "../../../helpers/api/request";
import { CurrentSelectedProject, IPermissionForm, IStudent } from "./types";

import css from "./students-table.scss";

interface IProps {
  classId: string;
  currentSelectedProject: CurrentSelectedProject;
}

type PermissionFormOption = {
  value: string;
  label: string;
};

const nonArchived = (forms: IPermissionForm[]) => forms.filter(form => !form.is_archived);

const bulkUpdatePermissionForms = async (
  { classId, selectedStudentIds, addFormIds, removeFormIds }:
  { classId: string; selectedStudentIds: string[]; addFormIds: string[]; removeFormIds: string[]; }
) =>
  request({
    url: Portal.API_V1.PERMISSION_FORMS_BULK_UPDATE,
    method: "POST",
    body: JSON.stringify({
      class_id: classId,
      student_ids: selectedStudentIds,
      add_permission_form_ids: addFormIds,
      remove_permission_form_ids: removeFormIds
    })
  });

export const StudentsTable = ({ classId }: IProps) => {
  const { data: studentsData, isLoading: studentsLoading, refetch: refetchStudentsData } =
    useFetch<IStudent[]>(Portal.API_V1.permissionFormsClassPermissionForms(classId), []);
  const { data: permissionForms, isLoading: permissionFormsLoading } = useFetch<IPermissionForm[]>(Portal.API_V1.PERMISSION_FORMS, []);
  const [isStudentSelected, setIsStudentSelected] = useState<Record<string, boolean>>({});
  const [permissionFormsToAdd, setPermissionFormsToAdd] = useState<readonly PermissionFormOption[]>([]);
  const [permissionFormsToRemove, setPermissionFormsToRemove] = useState<readonly PermissionFormOption[]>([]);
  const [requestInProgress, setRequestInProgress] = useState(false);

  const nonArchivedPermissionForms = nonArchived(permissionForms);
  const permissionFormToAddOptions = Object.freeze(
    nonArchivedPermissionForms.filter(pf => !permissionFormsToRemove.find(pfr => pfr.value === pf.id)).map(pf => ({ value: pf.id, label: pf.name }))
  );

  const permissionFormToRemoveOptions = Object.freeze(
    nonArchivedPermissionForms.filter(pf => !permissionFormsToAdd.find(pfr => pfr.value === pf.id)).map(pf => ({ value: pf.id, label: pf.name }))
  );

  // studentsData.length === 0 prevents the "Loading..." message from showing up when the students are re-fetched after update.
  if (studentsLoading && studentsData.length === 0) {
    return (<div>Loading...</div>);
  }
  if (!studentsData.length) {
    return (<div>No students found</div>);
  }

  const handleStudentSelectedToggle = (e: React.ChangeEvent<HTMLInputElement>) => {
    const studentId = e.target.name;
    if (e.target.checked) {
      setIsStudentSelected(prevIsStudentSelected => ({ ...prevIsStudentSelected, [studentId]: true }));
    } else {
      setIsStudentSelected(prevIsStudentSelected => {
        const { [studentId]: _, ...rest } = prevIsStudentSelected;
        return rest;
      });
    }
  };

  const handleSelectAllChange = () => {
    setIsStudentSelected(prevIsStudentSelected => {
      const _allStudentsSelected = Object.keys(prevIsStudentSelected).length === studentsData.length;
      if (_allStudentsSelected) {
        return {};
      }
      const result: Record<string, boolean> = {};
      studentsData.forEach(student => {
        result[student.id] = true;
      });
      return result;
    });
  };

  const handlePermissionFormToAddSelectChange = (selectedOptions: readonly PermissionFormOption[]) => {
    setPermissionFormsToAdd(selectedOptions);
  };

  const handlePermissionFormToRemoveSelectChange = (selectedOptions: readonly PermissionFormOption[]) => {
    setPermissionFormsToRemove(selectedOptions);
  };

  const handleSaveChanges = async () => {
    setRequestInProgress(true);
    const response = await bulkUpdatePermissionForms({
      classId,
      selectedStudentIds: Object.keys(isStudentSelected).filter(id => isStudentSelected[id]),
      addFormIds: permissionFormsToAdd.map(form => form.value),
      removeFormIds: permissionFormsToRemove.map(form => form.value)
    });
    setRequestInProgress(false);

    if (response) {
      refetchStudentsData();
      setPermissionFormsToAdd([]);
      setPermissionFormsToRemove([]);
    } else {
      alert("Failed to update permission forms");
    }
  };

  const selectedStudentsCount = Object.keys(isStudentSelected).length;
  const allStudentsSelected = Object.keys(isStudentSelected).length === studentsData.length;

  return (
    <table className={css.studentsTable}>
      <thead>
        <tr>
          <th className={css.checkboxColumn}><input type="checkbox" checked={allStudentsSelected} onChange={handleSelectAllChange} /></th>
          <th>Student Name</th>
          <th>Username</th>
          <th className={css.permissionFormsColumn}>Permission Forms</th>
          <th className={css.expandButtonColumn}></th>
        </tr>
      </thead>
      <tbody>
        {
          studentsData.map((studentInfo) => {
            return (
              <tr key={studentInfo.id}>
                <td className={css.checkboxColumn}>
                  <input type="checkbox" name={studentInfo.id} checked={isStudentSelected[studentInfo.id] ?? false} onChange={handleStudentSelectedToggle} />
                </td>
                <td>{ studentInfo.name }</td>
                <td>{ studentInfo.login }</td>
                <td className={css.permissionFormsColumn}>{ nonArchived(studentInfo.permission_forms).map(pf => pf.name).join(", ") }</td>
                <td className={css.expandButtonColumn}><button className={css.basicButton}>Edit</button></td>
              </tr>
            );
          })
        }
      </tbody>
      <tfoot>
        <tr>
          <td colSpan={5}>
            <div className={css.tableFooter}>
              <div className={css.summary}>
                { selectedStudentsCount } selected { selectedStudentsCount === 1 ? "student" : "students" }
              </div>
              <div className={css.permissionFormSelects}>
                <div className={css.selectContainer}>
                  Add:
                  <Select<PermissionFormOption, true>
                    classNames={{
                      option: () => css.permissionFormSelectOption
                    }}
                    className={css.permissionFormSelect}
                    options={permissionFormToAddOptions}
                    isMulti={true}
                    placeholder="Select permission form(s)..."
                    isLoading={permissionFormsLoading}
                    value={permissionFormsToAdd}
                    onChange={handlePermissionFormToAddSelectChange}
                  />
                </div>
                <div className={css.selectContainer}>
                  Remove:
                  <Select<PermissionFormOption, true>
                    classNames={{
                      option: () => css.permissionFormSelectOption
                    }}
                    className={css.permissionFormSelect}
                    options={permissionFormToRemoveOptions}
                    isMulti={true}
                    placeholder="Select permission form(s)..."
                    isLoading={permissionFormsLoading}
                    value={permissionFormsToRemove}
                    onChange={handlePermissionFormToRemoveSelectChange}
                  />
                </div>
              </div>
              <div>
                <button
                  className={css.saveChangesButton}
                  onClick={handleSaveChanges}
                  disabled={requestInProgress || selectedStudentsCount === 0 || permissionFormsToAdd.length === 0 && permissionFormsToRemove.length === 0}
                >
                  Save Changes
                </button>
                {
                  requestInProgress && <span className={css.updateInProgress}>Updating...</span>
                }
              </div>
            </div>
          </td>
        </tr>
      </tfoot>
    </table>
  );
};
