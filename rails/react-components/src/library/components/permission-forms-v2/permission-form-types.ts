export type CurrentSelectedProject = number | "";

export interface IPermissionForm {
  id: string;
  name: string;
  is_archived: boolean;
  project_id?: number | string; // need to fix this
  url?: string;
}

export type IPermissionFormFormData = Partial<IPermissionForm>;

export interface IProject {
  id: string;
  name: string;
}

export type PermissionsTab = "manageFormsTab" | "studentsTab";
