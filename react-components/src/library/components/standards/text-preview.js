import React from 'react'

export const PREVIEW_LENGTH = 17

const isArray = Array.isArray || (o => ({}).toString.call(o) === '[object Array]')

export default class TextPreview extends React.Component {
  constructor (props) {
    super(props)
    this.togglePreview = this.togglePreview.bind(this)
  }

  togglePreview (e) {
    const { config } = this.props
    config.preview = !config.preview
    this.setState({ config })
  }

  render () {
    let { text } = this.props.config
    const { preview } = this.props.config

    if (isArray(text)) {
      text = text.join(' ')
    }

    if (preview === true) {
      if (text.length > PREVIEW_LENGTH) {
        text = text.substring(0, PREVIEW_LENGTH) + ' ...'
      }
    }

    return (
      <div onClick={this.togglePreview} style={{ cursor: 'default' }}>
        {text}
      </div>
    )
  }
}
