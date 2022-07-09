import React from 'react'
import Component from '../helpers/component'
import cookieHelpers from '../helpers/cookie-helpers'

import css from './sitewide-alert.scss'

const SitewideAlert = Component({
  getInitialState: function () {
    return {
      alertDismissed: false,
      content: this.props.content,
      cookieName: cookieHelpers.setCookieName(this.props.content)
    }
  },

  componentWillMount: function () {
    const { cookieName } = this.state
    const alertDismissed = !!cookieHelpers.readCookie(cookieName)
    this.setState({ alertDismissed: alertDismissed })
  },

  handleAlertClose: function () {
    const { cookieName } = this.state
    cookieHelpers.createCookie(cookieName, 'true', 30)
    this.setState({ alertDismissed: true })
  },

  render: function () {
    const { alertDismissed, content } = this.state
    if (alertDismissed) {
      return null
    }
    return (
      <div className={css.alertBarContain}>
        <div className={css.alertBar__Text} onClick={this.handleAlertClose}>
          <div className={css.alertBar__Close} />
          <span dangerouslySetInnerHTML={{ __html: content }} />
        </div>
      </div>
    )
  }
})

export default SitewideAlert
