import React from "react";
import Modal from "./modal";
import css from "./modal-dialog.scss";

interface IProps {
  children?: React.ReactNode;
  title?: string;
  colorTheme?: "orange" | "teal";
}
export default class ModalDialog extends React.Component<IProps> {
  render () {
    const { title, children, colorTheme } = this.props;
    const themeClass = colorTheme || "teal";

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
