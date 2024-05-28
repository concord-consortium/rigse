import React from "react";

import Modal from "./modal";

import css from "./modal-dialog.scss";

export default class ModalDialog extends React.Component<any, any> {
  render () {
    const { title, children } = this.props;

    return (
      <Modal>
        <div className={css.dialog}>
          <div className={css.title}>{ title }</div>
          { children }
        </div>
      </Modal>
    );
  }
}
