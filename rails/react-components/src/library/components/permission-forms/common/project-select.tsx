import React from "react";
import { CurrentSelectedProject, IProject } from "./types";

interface IProjectSelectProps {
  projects: IProject[];
  onChange: (e: React.ChangeEvent<HTMLSelectElement>) => void;
  value?: CurrentSelectedProject;
}

export const ProjectSelect = ({ projects, value, onChange }: IProjectSelectProps) => {
  const sortedProjects = projects.sort((a, b) => a.name.localeCompare(b.name));
  return (
    <>
      <label>Project:</label>
      <select data-testid="project-select" value={value ?? undefined} name="project_id" onChange={onChange}>
        <option value="">Select a project...</option>
        { sortedProjects?.map((p: IProject) => <option key={p.id} value={p.id}>{ p.name }</option>) }
      </select>
    </>
  );
};
