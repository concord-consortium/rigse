import React from "react";
import css from "./style.scss";
import { IPermissionForm } from "./permission-form-types";

interface PermissionFormRowProps {
  permissionForm: IPermissionForm;
}

function ensureUrlProtocol(url: string): string {
  if (!url) {
    return "";
  }
  // Regular expression to check if the URL starts with http:// or https://
  const urlPattern = /^(http:\/\/|https:\/\/)/i;
  // If the URL does not start with http:// or https://, prepend https://
  if (!urlPattern.test(url)) {
      return `https://${url}`;
  }
  return url;
}

function renderLinkOrSpan(urlValue: string): React.ReactElement | string {
  const urlWithProtocol = ensureUrlProtocol(urlValue);
  try {
    const urlObj = new URL(urlWithProtocol);
    return <a href={urlObj.toString()} target="_blank">{urlObj.toString()}</a>;
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
