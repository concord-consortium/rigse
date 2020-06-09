import React from "react"
import {
  Edit, Create, SimpleForm, TextInput,
  Datagrid, List, TextField, EmailField
} from "react-admin"

export const UserList = props => (
  <List {...props}>
      <Datagrid rowClick="edit">
          <TextField source="id" />
          <TextField source="login" />
          <TextField source="firstName" />
          <TextField source="lastName" />
          <EmailField source="email" />
      </Datagrid>
  </List>
)

export const UserEdit = props => (
  <Edit {...props}>
    <SimpleForm>
        <TextInput source="firstName" />
        <TextInput source="lastName" />
        <TextInput source="email" />
    </SimpleForm>
  </Edit>
);

export const UserCreate = props => (
  <Create {...props}>
    <SimpleForm>
        <TextInput source="firstName" />
        <TextInput source="lastName" />
        <TextInput source="email" />
    </SimpleForm>
  </Create>
);
