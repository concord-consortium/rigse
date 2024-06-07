import React from "react";

import Modal from "./modal";

import css from "./modal-dialog.scss";

export default class ModalDialog extends React.Component<any, any> {
  render () {
    const { title, children, styles = {} } = this.props;

    return (
      <Modal>
        <div className={css.dialog} style={styles}>
          { title && <div className={css.title}>{ title }</div> }
          { children }
        </div>
      </Modal>
    );
  }
}
