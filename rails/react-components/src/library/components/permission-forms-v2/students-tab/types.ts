import { IPermissionForm } from "./types";

export { IPermissionForm, IProject, CurrentSelectedProject } from "../common/types";

export interface ITeacher {
  id: string;
  name: string;
  email: string;
  login: string;
}

export interface IStudent {
  id: string;
  name: string;
  login: string;
  permission_forms: IPermissionForm[];
}

export interface IClassBasicInfo {
  id: string;
  name: string;
  class_word: string;
}
