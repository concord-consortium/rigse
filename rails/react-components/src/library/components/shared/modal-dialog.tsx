import React from "react";
import Modal from "./modal";
import css from "./modal-dialog.scss";

interface IProps {
  children?: React.ReactNode;
  title?: string;
  borderColor?: "orange" | "teal";
}
export default class ModalDialog extends React.Component<IProps> {
  render () {
    const { title, children, borderColor } = this.props;
    const themeClass = borderColor || "teal";

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
  }
}
