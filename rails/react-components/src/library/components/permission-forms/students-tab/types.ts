import { IPermissionForm } from "./types";

export { IPermissionForm, IProject, CurrentSelectedProject } from "../common/types";

export interface ITeacher {
  id: number;
  name: string;
  email: string;
  login: string;
}

export interface IStudent {
  id: number;
  name: string;
  login: string;
  permission_forms: IPermissionForm[];
}

export interface IClassBasicInfo {
  id: number;
  name: string;
  class_word: string;
}
