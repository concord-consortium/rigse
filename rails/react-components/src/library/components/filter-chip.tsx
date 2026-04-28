import * as React from "react";

import css from "./filter-chip.scss";

export interface FilterChipProps {
  label: string;
  onRemove: () => void;
}

const DeleteIcon: React.FC = () => (
  <svg
    width="24" height="24" viewBox="0 0 24 24"
    xmlns="http://www.w3.org/2000/svg"
    aria-hidden="true"
    focusable="false"
  >
    <path
      d="M6.343 19.071 19.071 6.343 17.657 4.93 4.929 17.657l1.414 1.414zM4.93 6.343l12.728 12.728 1.414-1.414L6.343 4.929 4.93 6.343z"
      fill="currentColor"
      fillRule="nonzero"
    />
  </svg>
);

export const FilterChip: React.FC<FilterChipProps> = ({ label, onRemove }) => {
  return (
    <span className={css.chip}>
      <span className={css.chipLabel}>{label}</span>
      <button
        aria-label={`Remove filter: ${label}`}
        className={css.chipRemove}
        type="button"
        onClick={onRemove}
      >
        <DeleteIcon />
      </button>
    </span>
  );
};
