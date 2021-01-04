import React from "react"
import {
  Edit, Create,
  SimpleForm,
  BooleanInput, ReferenceInput, SelectInput,
  ReferenceField, TextField, FunctionField
} from "react-admin"

import { parse } from "query-string";

// Once created the project and user can't be changed
export const ProjectUserEdit = props => (
  <Edit {...props}>
    <SimpleForm redirect={(basePath, id, data) => `/User/${data.userId}`}>
      <ReferenceField label="Project" source="projectId" reference="AdminProject">
        <TextField source="name"/>
      </ReferenceField>
      <ReferenceField label="User" source="userId" reference="User">
        <FunctionField render={record => `${record.firstName} ${record.lastName}`} />
      </ReferenceField>
      <BooleanInput source="isAdmin"/>
      <BooleanInput source="isResearcher"/>
    </SimpleForm>
  </Edit>
);

// Create is always called from the User page with a userId so there isn't a need
// to edit the User field
export const ProjectUserCreate = props => {
  // Read the userId from the location which is injected by React Router
  // and passed to our component by react-admin automatically
  const { userId } = parse(props.location.search);
  const redirect = userId ? `/User/${userId}` : "/User";

  // FIXME: This form doesn't have good error handling if a duplicate project is
  // selected a notification will be shown below the form, but it disappears
  // too quickly. And the notification is not very useful.
  return (
    <Create title="Add user to a project" {...props}>
      <SimpleForm defaultValue={{userId}} redirect={redirect}>
        <ReferenceInput label="User" source="userId" reference="User">
          <SelectInput disabled={!!userId}
            optionText={record => `${record.firstName} ${record.lastName}`}/>
        </ReferenceInput>

        {/* TODO: this doesn't remove projects that the user has already been added to.
            the database has a unique index on projectId and userId so it should be rejected
            but it'd be better if the form limited the list. */}
        <ReferenceInput label="Project" source="projectId" reference="AdminProject">
          <SelectInput optionText="name"/>
        </ReferenceInput>
        <BooleanInput source="isAdmin"/>
        <BooleanInput source="isResearcher"/>
      </SimpleForm>
    </Create>
  );
};
