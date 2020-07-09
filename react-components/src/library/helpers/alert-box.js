import React from 'react'

import commonCss from '../styles/common-css-modules.scss'

export default class AlertBox extends React.Component {
  constructor (props) {
    super(props)

    this.state = {
      dismissed: false,
      alertMessage: this.props.alertMessage,
      buttonText: this.props.buttonText
    }

    this.closeAlertBox = this.closeAlertBox.bind(this)
  }

  closeAlertBox () {
    this.setState({ dismissed: true })
    this.props.callbackFunc()
  }

  render () {
    if (this.state.dismissed) {
      return (
        null
      )
    }
    return (
      <div className={commonCss.alertBox}>
        <div className={commonCss.feedbackCmessage}>
          {this.state.alertMessage}
        </div>
        <div className={commonCss.buttonsContainer}>
          <button onClick={this.closeAlertBox}>{this.state.buttonText}</button>
        </div>
      </div>
    )
  }
}
