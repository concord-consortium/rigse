import React from "react";
import { clsx } from "clsx";

import css from "./link-button.scss";

interface IProps {
  onClick?: () => void;
  children?: string | React.ReactNode;
  active?: boolean;
  disabled?: boolean;
}

export const LinkButton = ({ onClick, children, active, disabled }: IProps) => (
  <button
    className={clsx(css.linkButton, { [css.active]: active, [css.disabled]: disabled })}
    onClick={onClick}
  >
    { children }
  </button>
);
