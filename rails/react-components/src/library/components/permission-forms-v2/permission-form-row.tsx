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
    <tr className={css.permissionFormRow}>
      <td className={css.nameColumn}>{permissionForm.name}</td>
      <td className={css.urlColumn}>{permissionForm.url}</td>
      <td className={css.buttonsColumn}>
        <button className={css.basicButton}>Edit</button>
        <button className={css.basicButton}>Archive</button>
        <button className={css.basicButton}>Delete</button>
      </td>
    </tr>
  );
};

export default PermissionFormRow;
