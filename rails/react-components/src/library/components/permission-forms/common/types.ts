export type CurrentSelectedProject = number | null;

export interface IPermissionForm {
  id: number;
  name: string;
  is_archived: boolean;
  can_delete: boolean;
  project_id: CurrentSelectedProject;
  url?: string;
}

export interface IProject {
  id: number;
  name: string;
}

