import React from "react"
import {
  Edit, Create, SimpleForm, TextInput,
  Datagrid, List, TextField, EmailField,
  ReferenceArrayField, ChipField, SingleFieldList,
  ReferenceManyField, ReferenceField, BooleanField,
  EditButton, DeleteButton, Button, Link, Filter
} from "react-admin"

const UserFilter = (props) => (
  <Filter {...props}>
    <TextInput label="First Name" source="firstName" defaultValue="" />
    <TextInput label="Last Name" source="lastName" defaultValue="" />
    <TextInput label="Email" source="email" defaultValue="" />
  </Filter>
);

export const UserList = props => (
  <List {...props} filters={<UserFilter />}>
    <Datagrid rowClick="edit">
      <TextField source="id" />
      <TextField source="login" />
      <TextField source="firstName" />
      <TextField source="lastName" />
      <ReferenceArrayField label="projects" reference="AdminProject" source="projectsIds">
        <SingleFieldList>
          <ChipField source="name" />
        </SingleFieldList>
      </ReferenceArrayField>
      <EmailField source="email" />
    </Datagrid>
  </List>
)



const AddNewProjectUserButton = ({ record }) => (
  <Button
    component={Link}
    to={{
      pathname: "/AdminProjectUser/create",
      search: `?userId=${record.id}`,
    }}
    label="Add user to a new project"
  />
);

export const UserEdit = props => (
  <Edit {...props}>
    <SimpleForm>
      <TextInput source="firstName" />
      <TextInput source="lastName" />
      <TextInput source="email" />
      <ReferenceManyField label="Projects" reference="AdminProjectUser" target="userId">
        <Datagrid>
          <ReferenceField label="Project" source="projectId" reference="AdminProject">
            <TextField source="name" />
          </ReferenceField>
          <BooleanField label="Admin" source="isAdmin" />
          <BooleanField label="Researcher" source="isResearcher" />
          <EditButton />
          // Not obvious but redirecting to the empty string returns the user
          // to the current location
          <DeleteButton redirect="" />
        </Datagrid>
      </ReferenceManyField>
      <AddNewProjectUserButton {...props} />
    </SimpleForm>
  </Edit>
);

export const UserCreate = props => (
  <Create {...props}>
    <SimpleForm>
      <TextInput source="firstName" />
      <TextInput source="lastName" />
      <TextInput source="login" />
      <TextInput source="email" />
      <TextInput hidden={true} value="encryptedPassword" source="encryptedPassword" />
    </SimpleForm>
  </Create>
);
