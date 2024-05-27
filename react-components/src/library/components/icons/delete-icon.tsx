import React from 'react'

import css from './style.scss'

// NOTE: this uses a transparent svg image with a background url sized to show the delete icon
export default class DeleteIcon extends React.Component<any, any> {
  render () {
    const { title, disabled } = this.props
    const className = disabled ? css.deleteDisabledIcon : css.deleteIcon
    const transparentImage = 'data:image/svg+xml,<svg xmlns="http://www.w3.org/2000/svg"/>'
    return <img className={className} alt={title} src={transparentImage} title={title} />
  }
}
