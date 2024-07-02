import { IStudent } from "../students-tab/types";
import { CurrentSelectedProject, IPermissionForm } from "./types";

export const filteredByProject = (forms: IPermissionForm[], projectId: CurrentSelectedProject) => {
  return projectId === null
    ? forms
    : forms.filter((form: IPermissionForm) => form.project_id === projectId);
}

export const nonArchived = (forms: IPermissionForm[]) => {
  return forms.filter(form => !form.is_archived);
};

export const sortedByArchiveAndName = (forms: IPermissionForm[]) => forms.sort((a, b) => {
  if (a.is_archived === b.is_archived) {
    return a.name.localeCompare(b.name);
  }
  return a.is_archived ? 1 : -1;
});

export const formsOfStudent = (forms: IPermissionForm[], studentInfo: IStudent) => {
  const ids = studentInfo.permission_forms.map(form => form.id);
  return forms.filter(form => ids.includes(form.id));
}
