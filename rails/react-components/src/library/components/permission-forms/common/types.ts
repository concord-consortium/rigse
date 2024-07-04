export type CurrentSelectedProject = number | null;
export interface IPermissionForm {
  id: string;
  name: string;
  is_archived: boolean;
  can_delete: boolean;
  project_id: CurrentSelectedProject;
  url?: string;
}

export interface IProject {
  id: string;
  name: string;
}

