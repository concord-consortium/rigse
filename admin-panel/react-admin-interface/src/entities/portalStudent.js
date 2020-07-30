import React from "react"
import {
  Datagrid, DateField, List, TextField, ReferenceField, FunctionField
} from "react-admin"

export const PortalStudentList = props => (
  <List {...props}>
    <Datagrid>
      <TextField source="id" />
      <TextField source="userId" />
        <ReferenceField label="User" source="userId" reference="User">
          <FunctionField render={record => `${record.firstName} ${record.lastName}`} />
        </ReferenceField>
      <DateField source="createdAt" />
      <DateField source="updatedAt" />
    </Datagrid>
  </List>
)