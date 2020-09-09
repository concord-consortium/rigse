import React from 'react'

import css from './modal.scss'

export default class Modal extends React.Component {
  render () {
    const { children } = this.props

    return (
      <div className={css.modal}>
        <div className={css.background} />
        {children}
      </div>
    )
  }
}
