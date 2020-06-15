import React from "react"
import {
  List, Edit, Create,
  SimpleForm, Datagrid, TextField,
  DateField, BooleanField, BooleanInput, TextInput
} from "react-admin"

export const ProjectList = props => (
  <List {...props}>
    <Datagrid rowClick="edit">
      <TextField source="id" />
      <TextField source="name" />
      <DateField source="createdAt" />
      <DateField source="updatedAt" />
      <TextField source="landingPageSlug" />
      <TextField source="projectCardImageUrl" />
      <TextField source="projectCardDescription" />
      <BooleanField source="public" />
    </Datagrid>
  </List>
)

export const ProjectEdit = props => (
  <Edit {...props}>
    <SimpleForm>
      <TextInput source="name" />
      <TextInput source="landingPageSlug" />
      <TextInput source="projectCardImageUrl" />
      <TextInput source="projectCardDescription" />
      <BooleanInput source="public" />
    </SimpleForm>
  </Edit>
);

export const ProjectCreate = props => (
  <Create {...props}>
    <SimpleForm>
      <TextInput source="name" />
      <TextInput source="landingPageSlug" />
      <TextInput source="projectCardImageUrl" />
      <TextInput source="projectCardDescription" />
      <BooleanInput source="public" />
    </SimpleForm>
  </Create>
);