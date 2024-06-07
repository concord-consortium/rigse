import React from "react";
import css from "./style.scss";
import { IPermissionForm } from "./permission-form-types";


interface PermissionFormRowProps {
  permissionForm: IPermissionForm;
}

function renderLinkOrSpan(urlValue: string): React.ReactElement | string {
  try {
    const urlObj = new URL(urlValue);
    return <a href={urlObj.origin}>{urlObj.origin}</a>;
  } catch (_) {
    return <span className={css.invalidLink}>{urlValue}</span>;
  }
}

const PermissionFormRow: React.FC<PermissionFormRowProps> = ({ permissionForm }) => {
  return (
    <tr className={css.permissionFormRow}>
      <td className={css.nameColumn}>{permissionForm.name}</td>
      <td className={css.urlColumn}>{renderLinkOrSpan(permissionForm.url ?? "")}</td>
      <td className={css.buttonsColumn}>
        <button className={css.basicButton}>Edit</button>
        <button className={css.basicButton}>Archive</button>
        <button className={css.basicButton}>Delete</button>
      </td>
    </tr>
  );
};

export default PermissionFormRow;
