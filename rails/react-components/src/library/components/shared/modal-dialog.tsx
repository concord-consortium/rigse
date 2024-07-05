import React, { useEffect } from "react";
import Modal from "./modal";
import css from "./modal-dialog.scss";

interface IProps {
  children?: React.ReactNode;
  title?: string;
  borderColor?: "orange" | "teal";
}

const ModalDialog  = ({ title, children, borderColor }: IProps) => {
  const themeClass = borderColor || "teal";

  useEffect(() => {
    const previousOverflowValue = document.body.style.getPropertyValue("overflow");
    const previousOverflowPriority = document.body.style.getPropertyPriority("overflow");
    document.body.style.setProperty("overflow", "hidden", "important");
    return () => {
      document.body.style.setProperty("overflow", previousOverflowValue, previousOverflowPriority);
    };
  }, []);

  return (
    <Modal>
      <div className={`${css.dialog} ${css[themeClass]}`}>
        { title && <div className={css.dialogTitleBar}>{ title }</div> }
        <div className={css.dialogContent}>
          { children }
        </div>
      </div>
    </Modal>
  );
};

export default ModalDialog;
