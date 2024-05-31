import React, { useState, useEffect } from "react";
import css from "./style.scss";

interface PermissionFormRowProps {
  permissionForm: {
    id: string;
    name: string;
    url: string;
  };
}

const PermissionFormRow: React.FC<PermissionFormRowProps> = ({ permissionForm }) => {
  return (
    <tr>
      <td>{permissionForm.name}</td>
      <td>{permissionForm.url}</td>
      <td>{permissionForm.id}</td>
      <td>
        <button className={css.basicButton}>Edit</button>
        <button className={css.basicButton}>Archive</button>
        <button className={css.basicButton}>Delete</button>
      </td>
    </tr>
  );
};

export default PermissionFormRow;
