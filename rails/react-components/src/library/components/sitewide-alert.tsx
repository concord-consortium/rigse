import React from "react";
import Component from "../helpers/component";
import cookieHelpers from "../helpers/cookie-helpers";

import css from "./sitewide-alert.scss";

const SitewideAlert = Component({
  getInitialState () {
    return {
      alertDismissed: false,
      content: this.props.content,
      cookieName: cookieHelpers.setCookieName(this.props.content)
    };
  },

  componentWillMount () {
    const { cookieName } = this.state;
    const alertDismissed = !!cookieHelpers.readCookie(cookieName);
    this.setState({ alertDismissed });
  },

  handleAlertClose () {
    const { cookieName } = this.state;
    cookieHelpers.createCookie(cookieName, "true", 30);
    this.setState({ alertDismissed: true });
  },

  render () {
    const { alertDismissed, content } = this.state;
    if (alertDismissed) {
      return null;
    }
    return (
      <div className={css.alertBarContain}>
        <div className={css.alertBar__Text}>
          <div className={css.alertBar__Close} onClick={this.handleAlertClose} />
          <span dangerouslySetInnerHTML={{ __html: content }} />
        </div>
      </div>
    );
  }
});

export default SitewideAlert;
