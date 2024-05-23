import React from 'react'

import css from './modal.scss'

export default class Modal extends React.Component {
  render () {
    const { children } = this.props

    return (
      <div className={css.modal} role='dialog'>
        <div className={css.background} data-testid='modal-background' />
        {children}
      </div>
    )
  }
}
