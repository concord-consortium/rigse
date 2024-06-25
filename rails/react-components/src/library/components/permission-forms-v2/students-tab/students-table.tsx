import React, { useState } from "react";
import Select from "react-select";
import { useFetch } from "../../../hooks/use-fetch";
import { CurrentSelectedProject, IPermissionForm, IStudent } from "./types";

import css from "./students-table.scss";
import ModalDialog from "../../shared/modal-dialog";
import { EditStudentPermissionsForm } from "./edit-student-permissions-form";

interface IProps {
  classId: string;
  currentSelectedProject: CurrentSelectedProject;
}

type PermissionFormOption = {
  value: string;
  label: string;
};

export const StudentsTable = ({ classId }: IProps) => {
  const { data: studentsData, isLoading: studentsLoading } = useFetch<IStudent[]>(Portal.API_V1.permissionFormsClassPermissionForms(classId), []);
  const { data: permissionForms, isLoading: permissionFormsLoading } = useFetch<IPermissionForm[]>(Portal.API_V1.PERMISSION_FORMS, []);
  const [isStudentSelected, setIsStudentSelected] = useState<Record<string, boolean>>({});
  const [permissionFormsToAdd, setPermissionFormsToAdd] = useState<readonly PermissionFormOption[]>([]);
  const [permissionFormsToRemove, setPermissionFormsToRemove] = useState<readonly PermissionFormOption[]>([]);
  const [editStudent, setEditStudent] = useState<IStudent | null>(null);


  // When preparing the options for the Select component, we need to filter out the permission forms that are already
  // selected to add or remove in the opposite dropdown. Both permissionFormsToAdd and permissionFormsToRemove need
  // to be mutually exclusive.
  const permissionFormToAddOptions = Object.freeze(
    permissionForms.filter(pf => !permissionFormsToRemove.find(pfr => pfr.value === pf.id)).map(pf => ({ value: pf.id, label: pf.name }))
  );

  const permissionFormToRemoveOptions = Object.freeze(
    permissionForms.filter(pf => !permissionFormsToAdd.find(pfr => pfr.value === pf.id)).map(pf => ({ value: pf.id, label: pf.name }))
  );

  if (studentsLoading) {
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

  const selectedStudentsCount = Object.keys(isStudentSelected).length;
  const allStudentsSelected = Object.keys(isStudentSelected).length === studentsData.length;

  return (
    <>
      <table className={css.studentsTable}>
        <thead>
          <tr>
            <th><input type="checkbox" checked={allStudentsSelected} onChange={handleSelectAllChange} /></th>
            <th>Student Name</th>
            <th>Username</th>
            <th>Permission Forms</th>
            <th></th>
          </tr>
        </thead>
        <tbody>
          {
            studentsData.map((studentInfo) => {
              return (
                <tr key={studentInfo.id}>
                  <td><input type="checkbox" name={studentInfo.id} checked={isStudentSelected[studentInfo.id] ?? false} onChange={handleStudentSelectedToggle} /></td>
                  <td>{ studentInfo.name }</td>
                  <td>{ studentInfo.login }</td>
                  <td>{ studentInfo.permission_forms.map(pf => pf.name).join(", ") }</td>
                  <button className={css.basicButton} onClick={() => handleEditClick(studentInfo.id)}>Edit</button>
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
                      className={css.permissionFormSelect}
                      // TODO: temporarily ignoring typing issue that I cannot understand
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
                      className={css.permissionFormSelect}
                      // TODO: temporarily ignoring typing issue that I cannot understand
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
                  <button className={css.saveChangesButton}>Save Changes</button>
                </div>
              </div>
            </td>
          </tr>
        </tfoot>
      </table>
      { editStudent &&
        <ModalDialog borderColor="orange">
          <EditStudentPermissionsForm
            existingFormData={editStudent}
            student={editStudent}
            onFormSave={()=> console.log("| implement a save handler")}
            onFormCancel={() => setEditStudent(null)}
          />
        </ModalDialog>
      }
    </>
  );
};
