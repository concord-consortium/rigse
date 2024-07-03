import React, { useState } from "react";
import Select from "react-select";
import { useFetch } from "../../../hooks/use-fetch";
import { request } from "../../../helpers/api/request";
import { CurrentSelectedProject, IPermissionForm, IStudent } from "./types";
import { EditStudentPermissionsForm } from "./edit-student-permissions-form";
import { filteredByProject, formsOfStudent, nonArchived } from "../common/permission-utils";
import ModalDialog from "../../shared/modal-dialog";

import css from "./students-table.scss";

interface IProps {
  classId: string;
  currentSelectedProject: CurrentSelectedProject;
}

type PermissionFormOption = {
  value: string;
  label: string;
};


export const bulkUpdatePermissionForms = async (
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

export const StudentsTable = ({ classId, currentSelectedProject }: IProps) => {
  const { data: studentsData, isLoading: studentsLoading, refetch: refetchStudentsData } =
    useFetch<IStudent[]>(Portal.API_V1.permissionFormsClassPermissionForms(classId), []);
  const { data: permissionForms, isLoading: permissionFormsLoading } = useFetch<IPermissionForm[]>(Portal.API_V1.PERMISSION_FORMS, []);
  const [isStudentSelected, setIsStudentSelected] = useState<Record<string, boolean>>({});
  const [permissionFormsToAdd, setPermissionFormsToAdd] = useState<readonly PermissionFormOption[]>([]);
  const [permissionFormsToRemove, setPermissionFormsToRemove] = useState<readonly PermissionFormOption[]>([]);
  const [editStudent, setEditStudent] = useState<IStudent | null>(null);
  const [requestInProgress, setRequestInProgress] = useState(false);
  const [permissionsExpanded, setPermissionsExpanded] = useState(false);

  const currentForms = filteredByProject(nonArchived(permissionForms), currentSelectedProject).sort((a, b) => a.name.localeCompare(b.name));

  const permissionFormToAddOptions = Object.freeze(
    currentForms.filter(pf => !permissionFormsToRemove.find(pfr => pfr.value === pf.id)).map(pf => ({ value: pf.id, label: pf.name }))
  );

  const permissionFormToRemoveOptions = Object.freeze(
    currentForms.filter(pf => !permissionFormsToAdd.find(pfr => pfr.value === pf.id)).map(pf => ({ value: pf.id, label: pf.name }))
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

  const handleEditClick = (studentId: string) => {
    const student = studentsData.find(s => s.id === studentId);
    if (student) {
      setEditStudent(student);
    }
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

  // this is passed and called from onFormSave in EditStudentPermissionsForm
  // the actual API call happens there
  const handleSaveStudentPermissionsSuccess = async () => {
    setEditStudent(null);
    refetchStudentsData();
  };

  const handleClickPermissionExpandToggle = () => {
    setPermissionsExpanded(prevPermissionsExpanded => !prevPermissionsExpanded);
  };

  const selectedStudentsCount = Object.keys(isStudentSelected).length;
  const allStudentsSelected = Object.keys(isStudentSelected).length === studentsData.length;

  return (
    <>
      <table className={`${css.studentsTable} ${permissionsExpanded ? css.expandedPermissions : ""}`}>
        <thead>
          <tr>
            <th className={css.checkboxColumn}><input type="checkbox" checked={allStudentsSelected} onChange={handleSelectAllChange} /></th>
            <th>Student Name</th>
            <th>Username</th>
            <th className={css.permissionFormsColumn} colSpan={2}>
              <div role="button" onClick={handleClickPermissionExpandToggle}>
                Permission Forms
                { permissionsExpanded
                  ? <i className="icon icon-caret-up"></i>
                  : <i className="icon icon-caret-down"></i>
                }
              </div>
            </th>
          </tr>
        </thead>
        <tbody>
          {
            studentsData.map((studentInfo) => {
              const studentForms = formsOfStudent(currentForms, studentInfo);
              return (
                <tr key={studentInfo.id}>
                  <td className={css.checkboxColumn}>
                    <input type="checkbox" name={studentInfo.id} checked={isStudentSelected[studentInfo.id] ?? false} onChange={handleStudentSelectedToggle} />
                  </td>
                  <td>{ studentInfo.name }</td>
                  <td>{ studentInfo.login }</td>
                  <td className={css.permissionFormsColumn}>
                    {
                      studentForms.map((pf, i, forms) => (
                        <React.Fragment key={pf.id}>
                          { pf.name }
                          { i < forms.length - 1 && (permissionsExpanded ? <br /> : ", ") }
                        </React.Fragment>
                      ))
                    }
                  </td>
                  <td className={css.expandButtonColumn}>
                    <button className={css.basicButton} onClick={() => handleEditClick(studentInfo.id)}>Edit</button>
                  </td>
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
      { editStudent &&
        <ModalDialog borderColor="teal">
          <EditStudentPermissionsForm
            student={editStudent}
            permissionForms={currentForms}
            onFormCancel={() => setEditStudent(null)}
            onFormSave={handleSaveStudentPermissionsSuccess}
            classId={classId}
          />
        </ModalDialog>
      }
    </>
  );
};
