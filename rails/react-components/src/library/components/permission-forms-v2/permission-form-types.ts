export type CurrentSelectedProject = number | "";

export interface IPermissionForm {
  id: string;
  name: string;
  project_id?: number | string; // need to fix this
  url?: string;
 }

export interface IProject {
  id: string;
  name: string;
 }
