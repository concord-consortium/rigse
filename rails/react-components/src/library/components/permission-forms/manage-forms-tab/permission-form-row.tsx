import React from "react";
import { clsx } from "clsx";
import { IPermissionForm } from "./types";

import css from "./permission-form-row.scss";

interface PermissionFormRowProps {
  permissionForm: IPermissionForm;
  onEditModalToggle: (permissionForm: IPermissionForm) => void;
  onEdit: (permissionForm: IPermissionForm) => void;
  onDelete: (permissionFormId: number) => void;
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
  const urlWithProtocol = ensureUrlProtocol(urlValue.trim());
  try {
    const urlObj = new URL(urlWithProtocol);
    return <a href={urlObj.toString()} target="_blank" rel="noreferrer">{ urlObj.toString() }</a>;
  } catch (_) {
    return <span className={css.invalidLink}>{ urlValue }</span>;
  }
}

const PermissionFormRow: React.FC<PermissionFormRowProps> = ({ permissionForm, onEditModalToggle, onEdit, onDelete }) => {
  const handleEditModal = () => {
    onEditModalToggle(permissionForm);
  };

  const handleArchiveUnarchive = () => {
    if (window.confirm(`Are you sure you want to ${permissionForm.is_archived ? "unarchive" : "archive"} permission form "${permissionForm.name}"?`)) {
      onEdit({ ...permissionForm, is_archived: !permissionForm.is_archived });
    }
  };

  const handleDelete = () => {
    if (window.confirm(`Are you sure you want to delete permission form "${permissionForm.name}"?`)) {
      onDelete(permissionForm.id);
    }
  };

  return (
    <tr className={clsx(css.permissionFormRow, { [css.isArchived]: permissionForm.is_archived })}>
      <td className={css.nameColumn}>{ permissionForm.name }</td>
      <td className={css.urlColumn}>{ renderLinkOrSpan(permissionForm.url ?? "") }</td>
      <td className={css.editColumn}>
        <button className={css.basicButton} onClick={handleEditModal}>Edit</button>
      </td>
      <td className={css.archiveColumn}>
        <button className={css.basicButton} onClick={handleArchiveUnarchive}>
          { permissionForm.is_archived ? "Unarchive" : "Archive" }
        </button>
      </td>
      <td className={css.deleteColumn}>
        { permissionForm.can_delete && <button className={css.basicButton} onClick={handleDelete}>Delete</button> }
      </td>
    </tr>
  );
};

export default PermissionFormRow;
