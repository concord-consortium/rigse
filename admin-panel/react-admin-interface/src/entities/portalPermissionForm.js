import React from "react"
import {
  Edit, Create, SimpleForm, TextInput,
  Datagrid, List, TextField,
  ReferenceField,  Filter,
  ReferenceInput, SelectInput
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


export const PortalPermissionFormEdit = props => (
  <Edit {...props}>
    <SimpleForm>
      <TextInput source="name" />
      <TextInput source="url" />
      <ReferenceInput label="Project" source="projectId" reference="AdminProject">
        <SelectInput optionText="name" />
      </ReferenceInput>
    </SimpleForm>
  </Edit>
);

export const PortalPermissionFormCreate = props => (
  <Create {...props}>
    <SimpleForm>
      <TextInput source="name" />
      <TextInput source="url" />
    </SimpleForm>
  </Create>
);
