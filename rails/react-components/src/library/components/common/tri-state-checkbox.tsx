import React, { useEffect, useMemo, useRef } from "react";

import css from "./tri-state-checkbox.scss";

interface TriStateCheckboxProps {
  checked: boolean;
  partiallyChecked?: boolean;
  partiallyCheckedMessage?: string;
  disabled?: boolean;
  onChange: (checked: boolean) => void;
  id?: string;
  label?: string;
}

const TriStateCheckbox: React.FC<TriStateCheckboxProps> = ({
  checked,
  partiallyChecked,
  partiallyCheckedMessage,
  disabled,
  onChange,
  id,
  label,
}) => {
  const checkboxRef = useRef<HTMLInputElement>(null);

  const indeterminate = useMemo(() => {
    return partiallyChecked !== undefined && partiallyChecked;
  }, [checked, partiallyChecked]);

  const title = useMemo(() => {
    return indeterminate && partiallyCheckedMessage ? partiallyCheckedMessage : undefined;
  }, [indeterminate, partiallyCheckedMessage]);

  useEffect(() => {
    if (checkboxRef.current) {
      checkboxRef.current.indeterminate = indeterminate;
    }
  }, [indeterminate]);

  const handleChange = () => {
    if (disabled) return;
    onChange(!checked);
  };

  return (
    <label className={css.triStateCheckbox}>
      <input
        type="checkbox"
        ref={checkboxRef}
        checked={checked}
        disabled={disabled}
        onChange={handleChange}
        id={id}
        title={title}
      />
      {label && <span className={css.label}>{label}</span>}
    </label>
  );
};

export default TriStateCheckbox;
