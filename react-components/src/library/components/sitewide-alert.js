import React from 'react'
import Component from '../helpers/component'
import cookieHelpers from '../helpers/cookie-helpers'

import css from './sitewide-alert.scss'

const SitewideAlert = Component({
  getInitialState: function () {
    return {
      alertDismissed: false,
      content: this.props.content
    }
  },

  componentWillMount: function () {
    const alertDismissed = !!cookieHelpers.readCookie('sitewideAlertDismissed')
    this.setState({ alertDismissed: alertDismissed })
  },

  handleAlertClose: function (e) {
    // TODO: Make the cookie name unique to specific alert messages
    // and then drop the number of days option so people can
    // permanently dismiss specific alerts but be shown new ones
    // later on.
    cookieHelpers.createCookie('sitewideAlertDismissed', 'true', 30)
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
