import React from 'react'

export default class DisplayText extends React.Component {
  render () {
    return (
      <div>
        <span>{this.props.label + ': "'}</span>
        <span>{this.props.value + '"'}</span>
      </div>
    )
  }
}
