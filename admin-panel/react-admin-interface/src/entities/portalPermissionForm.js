import React from "react"
import {
  Edit, Create, SimpleForm, TextInput,
  Datagrid, List, TextField,
  ReferenceField,  Filter,
  ReferenceInput, SelectInput,
  ReferenceManyField, Button, Link,
  EditButton, BooleanField, DeleteButton
} from "react-admin"

const PermissionFilter = (props) => (
  <Filter {...props}>
    <TextInput label="name" source="name" defaultValue="" />
  </Filter>
);

export const PortalPermissionFormList = props => (
  <List {...props} filters={<PermissionFilter />}>
    <Datagrid rowClick="edit">
      <TextField source="id" />
      <TextField source="name" />
      <TextField source="url" />
      <ReferenceField label="project" reference="AdminProject" source="projectId">
        <TextField source="name" />
      </ReferenceField>
    </Datagrid>
  </List>
)

const AddNewStudentButton = ({ record }) => (
  <Button
    component={Link}
    to={{
      pathname: "/PortalStudentPermissionForm/create",
      search: `?portalPermissionFormId=${record.id}`,
    }}
    label="Add Student"
  />
);

export const PortalPermissionFormEdit = props => (
  <Edit {...props}>
    <SimpleForm>
      <TextInput source="name" />
      <TextInput source="url" />
      <ReferenceInput label="Project" source="projectId" reference="AdminProject">
        <SelectInput optionText="name" />
      </ReferenceInput>

      <ReferenceManyField
        label="forms"
        reference="PortalStudentPermissionForm"
        target="portalPermissionFormId"
        >
        <Datagrid>
          <ReferenceField label="student" source="portalStudentId" reference="PortalStudent">
            <TextField source="name" />
          </ReferenceField>
          <BooleanField label="Signed" source="signed" />
          <EditButton />{
            // Not obvious but redirecting to the empty string returns the user
            // to the current location
          }
          <DeleteButton redirect="" />
        </Datagrid>
      </ReferenceManyField>
      <AddNewStudentButton {...props} />
    </SimpleForm>
  </Edit>
);

export const PortalPermissionFormCreate = props => (
  <Create {...props}>
    <SimpleForm>
      <TextInput source="name" />
      <TextInput source="url" />
      <ReferenceInput label="Project" source="projectId" reference="AdminProject">
        <SelectInput optionText="name" />
      </ReferenceInput>
    </SimpleForm>
  </Create>
);
