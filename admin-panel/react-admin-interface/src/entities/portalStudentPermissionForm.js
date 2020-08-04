import React from "react"
import {
  Edit, Create,
  SimpleForm,
  BooleanInput, ReferenceInput, SelectInput,
  ReferenceField, TextField, FunctionField
} from "react-admin"

import { parse } from "query-string";

// Once created the project and user can't be changed
export const PortalStudentPermissionFormEdit = props => (
  <Edit {...props}>
    <SimpleForm redirect={(basePath, id, data) => `/PortalPermissionForm/${data.portalPermissionFormId}`}>
      <ReferenceField label="PermissionForm" source="portalPermissionFormId" reference="PortalPermissionForm">
        <TextField source="name"/>
      </ReferenceField>
      <ReferenceField label="Student" source="portalStudentId" reference="PortalStudent">
        <ReferenceField label="User" source="userId" reference="User">
          <FunctionField render={record => `${record.firstName} ${record.lastName}`} />
        </ReferenceField>
      </ReferenceField>
      <BooleanInput source="signed"/>
    </SimpleForm>
  </Edit>
);

// Create is always called from the PortalPermissionForm page with a
// portalPermissionFormId so there isn't a need to edit that field
export const PortalStudentPermissionFormCreate = props => {
  // Read the portalPermissionformId from the location which is injected by React Router
  // and passed to our component by react-admin automatically
  const portalPermissionFormId = parse(props.location.search).portalPermissionFormId;
  const redirect = portalPermissionFormId ?
    `/PortalPermissionForm/${portalPermissionFormId}`
    : "/PortalPermissionForm";

  // FIXME: This form doesn't have good error handling if a duplicate Student
  // is selected a notification will be shown below the form, but it disappears
  // too quickly. And the notification is not very useful.
  return (
    <Create title="Add student permission form" {...props}>
      <SimpleForm defaultValue={{portalPermissionFormId}} redirect={redirect}>
        <ReferenceField
          label="Permission Form"
          source="portalPermissionFormId"
          reference="PortalPermissionform">
          <TextField source="name" />
        </ReferenceField>

        {/* TODO: this doesn't remove projects that the user has already been added to.
            the database has a unique index on projectId and userId so it should be rejected
            but it'd be better if the form limited the list. */}
        <ReferenceInput label="Student" source="portalStudentId" reference="PortalStudent">
          <SelectInput optionText="name"/>
        </ReferenceInput>
        <BooleanInput source="signed"/>
      </SimpleForm>
    </Create>
  );
};
